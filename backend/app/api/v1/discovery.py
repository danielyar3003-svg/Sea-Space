"""Discovery engine endpoints. Research results are returned for review; importing is a
separate, explicit user action."""

import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Request, status
from pydantic import AnyHttpUrl, BaseModel, Field
from sqlalchemy import select
from starlette.concurrency import run_in_threadpool

from app.api.deps import CurrentUser, DbDep, SettingsDep, audit
from app.core.config import Settings, get_settings
from app.models import (
    Company,
    CompanyContact,
    CompanySource,
    CompanyWebsite,
    ContactSource,
    SearchHistory,
)
from app.services.companies import LIVE, get_company
from app.services.discovery.fetcher import FetchError, SafeFetcher
from app.services.discovery.research import (
    RESEARCH_TARGETS,
    SearchNotConfigured,
    research_website,
    web_search,
)
from app.services.normalize import is_generic_mailbox, normalize_company_name

router = APIRouter(prefix="/discovery", tags=["discovery"])


def get_fetcher(settings: Annotated[Settings, Depends(get_settings)]):  # noqa: ANN201
    fetcher = SafeFetcher(allow_private_hosts=settings.discovery_allow_private_hosts,
                          min_interval=settings.discovery_min_interval_seconds)
    try:
        yield fetcher
    finally:
        fetcher.close()


class WebsiteResearchIn(BaseModel):
    url: AnyHttpUrl
    company_id: uuid.UUID | None = None


class SearchIn(BaseModel):
    query: str = Field(min_length=2, max_length=300)


class TargetOut(BaseModel):
    name: str
    company_id: uuid.UUID | None


@router.post("/website")
async def research_site(body: WebsiteResearchIn, request: Request, user: CurrentUser, db: DbDep,
                        fetcher: Annotated[SafeFetcher, Depends(get_fetcher)]) -> dict:
    """Read a company's public website (home + up to 3 careers/contact pages) and return
    findings with source URLs. Respects robots.txt and rate limits."""
    company = get_company(db, user, body.company_id) if body.company_id else None
    try:
        report = await run_in_threadpool(research_website, str(body.url), fetcher)
    except FetchError as exc:
        raise HTTPException(422, str(exc)) from exc
    db.add(SearchHistory(user_id=user.id, kind="website_research", query=str(body.url),
                         filters={"company_id": str(company.id) if company else None},
                         results_count=len(report.findings)))
    if company and report.pages_checked:
        for page in report.pages_checked:
            db.add(CompanySource(user_id=user.id, company_id=company.id, url=page,
                                 source_type="official_website", title="Website research",
                                 fields_supported=[]))
    audit(db, request, user, "discovery.website", "company",
          company.id if company else None, pages=len(report.pages_checked))
    db.commit()
    return report.to_dict()


@router.post("/search")
async def search(body: SearchIn, user: CurrentUser, db: DbDep, settings: SettingsDep) -> dict:
    key = settings.brave_search_api_key.get_secret_value() if settings.brave_search_api_key else None
    try:
        findings = await run_in_threadpool(web_search, body.query, key)
    except SearchNotConfigured as exc:
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, str(exc)) from exc
    db.add(SearchHistory(user_id=user.id, kind="web_search", query=body.query,
                         results_count=len(findings)))
    db.commit()
    return {
        "query": body.query,
        "findings": [f.__dict__ for f in findings],
        "limitations": ["Search snippets are leads only. Open each page and check it before "
                        "saving anything as a fact."],
    }


@router.get("/targets", response_model=list[TargetOut])
def research_targets(user: CurrentUser, db: DbDep) -> list[TargetOut]:
    """Starting research targets from the product brief (not an exclusive list)."""
    existing = {c.normalized_name: c.id for c in db.scalars(
        select(Company).where(Company.user_id == user.id, *LIVE))}
    return [TargetOut(name=n, company_id=existing.get(normalize_company_name(n)))
            for n in RESEARCH_TARGETS]


@router.post("/targets/import", response_model=list[TargetOut])
def import_targets(request: Request, user: CurrentUser, db: DbDep) -> list[TargetOut]:
    """Add the brief's research targets as companies with only a name. Everything else
    (country, website, hiring status) stays unknown until researched."""
    existing = {c.normalized_name for c in db.scalars(
        select(Company).where(Company.user_id == user.id, *LIVE))}
    for name in RESEARCH_TARGETS:
        norm = normalize_company_name(name)
        if norm in existing:
            continue
        company = Company(user_id=user.id, name=name, normalized_name=norm,
                          hiring_status="unknown", verification_status="user_provided")
        db.add(company)
        db.flush()
        db.add(CompanySource(user_id=user.id, company_id=company.id, source_type="user_entry",
                             title="Research target from the SEA SPACE brief"))
    audit(db, request, user, "discovery.targets_imported")
    db.commit()
    return research_targets(user, db)


class ImportFindingIn(BaseModel):
    company_id: uuid.UUID
    kind: str = Field(pattern="^(email|careers_page|contact_page|speculative_policy)$")
    value: str = Field(min_length=1, max_length=2000)
    source_url: AnyHttpUrl
    excerpt: str | None = Field(default=None, max_length=5000)


@router.post("/import", status_code=201)
def import_finding(body: ImportFindingIn, request: Request, user: CurrentUser,
                   db: DbDep) -> dict:
    """Save one reviewed finding onto a company. Imported data stays `unverified` until the
    user verifies it."""
    company = get_company(db, user, body.company_id)
    src = str(body.source_url)
    result: dict = {"kind": body.kind}
    if body.kind == "email":
        email = body.value.strip().lower()
        if db.scalar(select(CompanyContact).where(
                CompanyContact.user_id == user.id, CompanyContact.company_id == company.id,
                CompanyContact.email == email, CompanyContact.deleted_at.is_(None))):
            raise HTTPException(status.HTTP_409_CONFLICT, "E-mail already saved for this company")
        contact = CompanyContact(
            user_id=user.id, company_id=company.id, email=email,
            contact_kind="generic_inbox" if is_generic_mailbox(email) else "person",
            email_status="public_unverified", source_url=src,
            verification_status="unverified", contact_status="new")
        db.add(contact)
        db.flush()
        db.add(ContactSource(user_id=user.id, contact_id=contact.id, url=src,
                             excerpt=body.excerpt))
        result["contact_id"] = str(contact.id)
    elif body.kind in ("careers_page", "contact_page"):
        kind = "careers" if body.kind == "careers_page" else "contact"
        url = body.value.strip()
        if not db.scalar(select(CompanyWebsite).where(CompanyWebsite.company_id == company.id,
                                                      CompanyWebsite.url == url)):
            db.add(CompanyWebsite(user_id=user.id, company_id=company.id, url=url, kind=kind))
        if kind == "careers" and not company.careers_url:
            company.careers_url = url
    elif body.kind == "speculative_policy":
        company.speculative_policy = body.value
        if company.hiring_status == "unknown":
            company.hiring_status = "speculative_accepted"
    db.add(CompanySource(user_id=user.id, company_id=company.id, url=src,
                         source_type="official_website", excerpt=body.excerpt,
                         fields_supported=[body.kind]))
    audit(db, request, user, "discovery.imported", "company", company.id, kind=body.kind)
    db.commit()
    return result
