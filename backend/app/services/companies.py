"""Company domain logic shared by routers: lookups, summaries, duplicate detection, merging."""

import uuid
from datetime import UTC, datetime

from fastapi import HTTPException, status
from sqlalchemy import func, select, update
from sqlalchemy.orm import Session

from app.models import (
    AIGeneratedDraft,
    Company,
    CompanyContact,
    CompanyIndustry,
    CompanyNote,
    CompanySource,
    CompanyWebsite,
    EmailThread,
    FollowUpTask,
    JobApplication,
    SalaryOffer,
    User,
    Vacancy,
    VesselOperator,
    VesselOwner,
)
from app.services.normalize import name_similarity, registrable_domain

LIVE = (Company.deleted_at.is_(None), Company.merged_into_id.is_(None))


def get_company(db: Session, user: User, company_id: uuid.UUID) -> Company:
    company = db.scalar(select(Company).where(Company.id == company_id,
                                              Company.user_id == user.id, *LIVE))
    if company is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Company not found")
    return company


def industries_by_company(db: Session, user: User, ids: list[uuid.UUID]) -> dict[uuid.UUID, list[str]]:
    out: dict[uuid.UUID, list[str]] = {i: [] for i in ids}
    if not ids:
        return out
    rows = db.execute(select(CompanyIndustry.company_id, CompanyIndustry.industry).where(
        CompanyIndustry.user_id == user.id, CompanyIndustry.company_id.in_(ids)))
    for cid, ind in rows:
        out[cid].append(ind)
    for v in out.values():
        v.sort()
    return out


def counts_by_company(db: Session, user: User, ids: list[uuid.UUID]) -> tuple[dict, dict]:
    if not ids:
        return {}, {}
    contacts = dict(db.execute(
        select(CompanyContact.company_id, func.count()).where(
            CompanyContact.user_id == user.id, CompanyContact.company_id.in_(ids),
            CompanyContact.deleted_at.is_(None)).group_by(CompanyContact.company_id)).all())
    vacancies = dict(db.execute(
        select(Vacancy.company_id, func.count()).where(
            Vacancy.user_id == user.id, Vacancy.company_id.in_(ids), Vacancy.status == "active",
            Vacancy.deleted_at.is_(None)).group_by(Vacancy.company_id)).all())
    return contacts, vacancies


def set_industries(db: Session, user: User, company: Company, industries: list[str]) -> None:
    db.query(CompanyIndustry).filter(CompanyIndustry.company_id == company.id,
                                     CompanyIndustry.user_id == user.id).delete()
    for ind in sorted(set(industries)):
        db.add(CompanyIndustry(user_id=user.id, company_id=company.id, industry=str(ind)))


def company_domains(db: Session, user: User, company: Company) -> set[str]:
    urls = [w for (w,) in db.execute(select(CompanyWebsite.url).where(
        CompanyWebsite.company_id == company.id, CompanyWebsite.user_id == user.id))]
    urls += [company.careers_url, company.source_url]
    return {d for d in (registrable_domain(u) for u in urls if u) if d}


def find_duplicates(db: Session, user: User, normalized_name: str, country: str | None,
                    domains: set[str] | None = None,
                    exclude: uuid.UUID | None = None) -> list[tuple[Company, str, float]]:
    """Likely duplicates of a (new or existing) company within the user's workspace."""
    companies = db.scalars(select(Company).where(Company.user_id == user.id, *LIVE)).all()
    domains = domains or set()
    site_domains: dict[uuid.UUID, set[str]] = {}
    if domains:
        for cid, url in db.execute(select(CompanyWebsite.company_id, CompanyWebsite.url).where(
                CompanyWebsite.user_id == user.id)):
            d = registrable_domain(url)
            if d:
                site_domains.setdefault(cid, set()).add(d)
    found = []
    for c in companies:
        if c.id == exclude:
            continue
        shared = domains & site_domains.get(c.id, set())
        if shared:
            found.append((c, f"Same website domain ({sorted(shared)[0]})", 1.0))
            continue
        score = name_similarity(normalized_name, c.normalized_name)
        if c.normalized_name == normalized_name:
            same_country = (country or "") == (c.country_code or "")
            found.append((c, "Same name" + ("" if same_country else " (different country)"), 1.0))
        elif score >= 0.88:
            found.append((c, "Very similar name", round(score, 2)))
    return sorted(found, key=lambda t: -t[2])


def all_duplicate_pairs(db: Session, user: User) -> list[tuple[Company, Company, str, float]]:
    companies = db.scalars(select(Company).where(Company.user_id == user.id, *LIVE)
                           .order_by(Company.created_at)).all()
    domains: dict[uuid.UUID, set[str]] = {}
    for cid, url in db.execute(select(CompanyWebsite.company_id, CompanyWebsite.url).where(
            CompanyWebsite.user_id == user.id)):
        d = registrable_domain(url)
        if d:
            domains.setdefault(cid, set()).add(d)
    pairs = []
    for i, a in enumerate(companies):
        for b in companies[i + 1:]:
            shared = domains.get(a.id, set()) & domains.get(b.id, set())
            if shared:
                pairs.append((a, b, f"Same website domain ({sorted(shared)[0]})", 1.0))
            elif a.normalized_name == b.normalized_name:
                pairs.append((a, b, "Same name", 1.0))
            else:
                s = name_similarity(a.normalized_name, b.normalized_name)
                if s >= 0.88:
                    pairs.append((a, b, "Very similar name", round(s, 2)))
    return pairs


def merge_companies(db: Session, user: User, source: Company, target: Company) -> None:
    """Move everything from `source` onto `target`; `source` stays as a hidden merged record."""
    if source.id == target.id:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Cannot merge a company into itself")
    for model in (CompanyContact, CompanySource, CompanyNote, Vacancy, JobApplication,
                  EmailThread, FollowUpTask, SalaryOffer, AIGeneratedDraft):
        db.execute(update(model).where(model.user_id == user.id, model.company_id == source.id)
                   .values(company_id=target.id))
    for link in (VesselOwner, VesselOperator):
        existing = {(v, f) for v, f in db.execute(select(link.vessel_id, link.valid_from).where(
            link.company_id == target.id))}
        for row in db.scalars(select(link).where(link.company_id == source.id)):
            if (row.vessel_id, row.valid_from) in existing:
                db.delete(row)
            else:
                row.company_id = target.id
    target_urls = {u for (u,) in db.execute(select(CompanyWebsite.url).where(
        CompanyWebsite.company_id == target.id))}
    for w in db.scalars(select(CompanyWebsite).where(CompanyWebsite.company_id == source.id)):
        if w.url in target_urls:
            db.delete(w)
        else:
            w.company_id = target.id
    target_inds = {i for (i,) in db.execute(select(CompanyIndustry.industry).where(
        CompanyIndustry.company_id == target.id))}
    for ci in db.scalars(select(CompanyIndustry).where(CompanyIndustry.company_id == source.id)):
        if ci.industry not in target_inds:
            db.add(CompanyIndustry(user_id=user.id, company_id=target.id, industry=ci.industry))
        db.delete(ci)
    # Fill gaps on the target with the source's values; never overwrite target data.
    for field in ("country_code", "headquarters", "speculative_policy", "careers_url",
                  "recruitment_email", "fleet_summary", "description", "latitude", "longitude"):
        if getattr(target, field) is None and getattr(source, field) is not None:
            setattr(target, field, getattr(source, field))
    if target.hiring_status == "unknown" and source.hiring_status != "unknown":
        target.hiring_status = source.hiring_status
    source.merged_into_id = target.id
    source.deleted_at = datetime.now(UTC)
