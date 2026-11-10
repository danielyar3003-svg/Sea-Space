import uuid
from datetime import UTC, datetime
from typing import Annotated

from fastapi import APIRouter, HTTPException, Query, Request, Response, status
from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser, DbDep, audit
from app.models import (
    Company,
    CompanyIndustry,
    CompanyNote,
    CompanySource,
    CompanyWebsite,
    User,
    Vessel,
    VesselOperator,
    VesselOwner,
)
from app.models.enums import HiringStatus, Industry
from app.schemas.company import (
    CompanyCreate,
    CompanyDetail,
    CompanySummary,
    CompanyUpdate,
    DuplicateCandidate,
    DuplicatePair,
    MergeIn,
    NoteIn,
    NoteOut,
    SourceIn,
    SourceOut,
    VerifyIn,
    VesselLink,
    WebsiteIn,
    WebsiteOut,
)
from app.services.companies import (
    LIVE,
    all_duplicate_pairs,
    company_domains,
    counts_by_company,
    find_duplicates,
    get_company,
    industries_by_company,
    merge_companies,
    set_industries,
)
from app.services.normalize import normalize_company_name, registrable_domain

router = APIRouter(prefix="/companies", tags=["companies"])


def _summaries(db: Session, user: User, companies: list[Company]) -> list[CompanySummary]:
    ids = [c.id for c in companies]
    inds = industries_by_company(db, user, ids)
    contacts, vacancies = counts_by_company(db, user, ids)
    return [
        CompanySummary.model_validate(c).model_copy(update={
            "industries": inds.get(c.id, []),
            "contacts_count": contacts.get(c.id, 0),
            "open_vacancies_count": vacancies.get(c.id, 0),
        })
        for c in companies
    ]


def _vessel_links(db: Session, user: User, company_id: uuid.UUID) -> list[VesselLink]:
    links: list[VesselLink] = []
    for model, role in ((VesselOwner, "owner"), (VesselOperator, "operator")):
        rows = db.execute(
            select(model, Vessel.name, Company.name)
            .join(Vessel, Vessel.id == model.vessel_id)
            .join(Company, Company.id == model.company_id)
            .where(model.user_id == user.id, model.company_id == company_id,
                   Vessel.deleted_at.is_(None)))
        for link, vessel_name, company_name in rows:
            links.append(VesselLink(
                id=link.id, role=role, vessel_id=link.vessel_id, vessel_name=vessel_name,
                company_id=link.company_id, company_name=company_name,
                valid_from=link.valid_from, valid_to=link.valid_to,
                is_crewing_employer=getattr(link, "is_crewing_employer", None),
                verification_status=link.verification_status, source_url=link.source_url))
    return sorted(links, key=lambda v: v.vessel_name.lower())


def _detail(db: Session, user: User, company: Company) -> CompanyDetail:
    summary = _summaries(db, user, [company])[0]
    websites = db.scalars(select(CompanyWebsite).where(
        CompanyWebsite.company_id == company.id, CompanyWebsite.user_id == user.id)
        .order_by(CompanyWebsite.created_at)).all()
    sources = db.scalars(select(CompanySource).where(
        CompanySource.company_id == company.id, CompanySource.user_id == user.id)
        .order_by(CompanySource.retrieved_at.desc())).all()
    notes = db.scalars(select(CompanyNote).where(
        CompanyNote.company_id == company.id, CompanyNote.user_id == user.id,
        CompanyNote.deleted_at.is_(None)).order_by(CompanyNote.created_at.desc())).all()
    return CompanyDetail.model_validate(company).model_copy(update={
        **summary.model_dump(include={"industries", "contacts_count", "open_vacancies_count"}),
        "websites": [WebsiteOut.model_validate(w) for w in websites],
        "sources": [SourceOut.model_validate(s) for s in sources],
        "notes": [NoteOut.model_validate(n) for n in notes],
        "vessels": _vessel_links(db, user, company.id),
    })


@router.get("", response_model=list[CompanySummary])
def list_companies(
    user: CurrentUser,
    db: DbDep,
    q: Annotated[str | None, Query(max_length=200)] = None,
    country: Annotated[str | None, Query(min_length=2, max_length=2)] = None,
    hiring_status: HiringStatus | None = None,
    industry: Industry | None = None,
    verified: bool | None = None,
    limit: Annotated[int, Query(ge=1, le=200)] = 50,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> list[CompanySummary]:
    stmt = select(Company).where(Company.user_id == user.id, *LIVE)
    if q:
        like = f"%{q.strip()}%"
        stmt = stmt.where(or_(Company.name.ilike(like), Company.normalized_name.ilike(
            f"%{normalize_company_name(q)}%"), Company.headquarters.ilike(like)))
    if country:
        stmt = stmt.where(Company.country_code == country.upper())
    if hiring_status:
        stmt = stmt.where(Company.hiring_status == hiring_status)
    if industry:
        stmt = stmt.where(Company.id.in_(select(CompanyIndustry.company_id).where(
            CompanyIndustry.user_id == user.id, CompanyIndustry.industry == industry)))
    if verified is not None:
        stmt = stmt.where((Company.verification_status == "verified") == verified)
    companies = db.scalars(stmt.order_by(Company.name).limit(limit).offset(offset)).all()
    return _summaries(db, user, list(companies))


@router.post("", response_model=CompanyDetail, status_code=status.HTTP_201_CREATED,
             responses={409: {"description": "Likely duplicate; resend with allow_duplicate"}})
def create_company(body: CompanyCreate, request: Request, user: CurrentUser,
                   db: DbDep) -> CompanyDetail:
    normalized = normalize_company_name(body.name)
    urls = [str(w.url) for w in body.websites] + ([str(body.careers_url)] if body.careers_url else [])
    domains = {d for d in (registrable_domain(u) for u in urls) if d}
    dups = find_duplicates(db, user, normalized, body.country_code, domains)
    exact_same = [c for c, reason, _ in dups if reason in ("Same name",)
                  and (c.country_code or "") == (body.country_code or "")]
    if exact_same or (dups and not body.allow_duplicate):
        raise HTTPException(status.HTTP_409_CONFLICT, {
            "message": "A similar company already exists",
            "candidates": [DuplicateCandidate(id=c.id, name=c.name, country_code=c.country_code,
                                              reason=r, score=s).model_dump(mode="json")
                           for c, r, s in dups],
            "can_override": not exact_same,
        })
    data = body.model_dump(exclude={"industries", "websites", "allow_duplicate", "source_url"},
                           mode="json")
    company = Company(user_id=user.id, normalized_name=normalized,
                      source_url=str(body.source_url) if body.source_url else None,
                      verification_status="unverified" if body.source_url else "user_provided",
                      **data)
    db.add(company)
    db.flush()
    set_industries(db, user, company, [str(i) for i in body.industries])
    for w in body.websites:
        db.add(CompanyWebsite(user_id=user.id, company_id=company.id, url=str(w.url), kind=w.kind))
    if body.source_url:
        db.add(CompanySource(user_id=user.id, company_id=company.id, url=str(body.source_url),
                             source_type="user_entry"))
    audit(db, request, user, "company.created", "company", company.id)
    db.commit()
    return _detail(db, user, company)


@router.get("/duplicates", response_model=list[DuplicatePair])
def list_duplicates(user: CurrentUser, db: DbDep) -> list[DuplicatePair]:
    return [
        DuplicatePair(
            a=DuplicateCandidate(id=a.id, name=a.name, country_code=a.country_code,
                                 reason=reason, score=score),
            b=DuplicateCandidate(id=b.id, name=b.name, country_code=b.country_code,
                                 reason=reason, score=score),
        )
        for a, b, reason, score in all_duplicate_pairs(db, user)
    ]


@router.get("/{company_id}", response_model=CompanyDetail)
def get_company_detail(company_id: uuid.UUID, user: CurrentUser, db: DbDep) -> CompanyDetail:
    return _detail(db, user, get_company(db, user, company_id))


@router.patch("/{company_id}", response_model=CompanyDetail)
def update_company(company_id: uuid.UUID, body: CompanyUpdate, request: Request,
                   user: CurrentUser, db: DbDep) -> CompanyDetail:
    company = get_company(db, user, company_id)
    changes = body.model_dump(exclude_unset=True, mode="json")
    industries = changes.pop("industries", None)
    if "name" in changes:
        normalized = normalize_company_name(changes["name"])
        clash = [c for c, r, _ in find_duplicates(db, user, normalized,
                                                  changes.get("country_code", company.country_code),
                                                  exclude=company.id)
                 if r == "Same name"]
        if clash:
            raise HTTPException(status.HTTP_409_CONFLICT,
                                f"Another company is already named '{clash[0].name}'. Merge instead.")
        company.normalized_name = normalized
    for field, value in changes.items():
        setattr(company, field, value)
    if industries is not None:
        set_industries(db, user, company, industries)
    audit(db, request, user, "company.updated", "company", company.id, fields=sorted(changes))
    db.commit()
    return _detail(db, user, company)


@router.delete("/{company_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_company(company_id: uuid.UUID, request: Request, user: CurrentUser,
                   db: DbDep) -> Response:
    company = get_company(db, user, company_id)
    company.deleted_at = datetime.now(UTC)
    audit(db, request, user, "company.deleted", "company", company.id)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/{company_id}/verify", response_model=CompanyDetail)
def verify_company(company_id: uuid.UUID, body: VerifyIn, request: Request, user: CurrentUser,
                   db: DbDep) -> CompanyDetail:
    """The user confirms the company details against a source they checked."""
    company = get_company(db, user, company_id)
    company.source_url = str(body.source_url)
    company.last_verified_at = datetime.now(UTC)
    company.verification_status = "verified"
    company.confidence = body.confidence
    db.add(CompanySource(user_id=user.id, company_id=company.id, url=str(body.source_url),
                         source_type="user_entry", title="Verified by user"))
    audit(db, request, user, "company.verified", "company", company.id)
    db.commit()
    return _detail(db, user, company)


@router.post("/{company_id}/merge", response_model=CompanyDetail)
def merge_company(company_id: uuid.UUID, body: MergeIn, request: Request, user: CurrentUser,
                  db: DbDep) -> CompanyDetail:
    """Merge this company INTO `into_id`. Contacts, vacancies, applications, notes, sources,
    websites and vessel links move to the target; the source is kept as a hidden record."""
    source = get_company(db, user, company_id)
    target = get_company(db, user, body.into_id)
    merge_companies(db, user, source, target)
    audit(db, request, user, "company.merged", "company", source.id, into=str(target.id))
    db.commit()
    return _detail(db, user, target)


# --- Websites, sources, notes ---------------------------------------------------------------


@router.post("/{company_id}/websites", response_model=WebsiteOut, status_code=201)
def add_website(company_id: uuid.UUID, body: WebsiteIn, user: CurrentUser,
                db: DbDep) -> CompanyWebsite:
    company = get_company(db, user, company_id)
    url = str(body.url)
    if db.scalar(select(CompanyWebsite).where(CompanyWebsite.company_id == company.id,
                                              CompanyWebsite.url == url)):
        raise HTTPException(status.HTTP_409_CONFLICT, "Website already added")
    site = CompanyWebsite(user_id=user.id, company_id=company.id, url=url, kind=body.kind)
    db.add(site)
    db.commit()
    return site


@router.delete("/{company_id}/websites/{website_id}", status_code=204)
def delete_website(company_id: uuid.UUID, website_id: uuid.UUID, user: CurrentUser,
                   db: DbDep) -> Response:
    get_company(db, user, company_id)
    site = db.scalar(select(CompanyWebsite).where(
        CompanyWebsite.id == website_id, CompanyWebsite.company_id == company_id,
        CompanyWebsite.user_id == user.id))
    if site is None:
        raise HTTPException(404, "Website not found")
    db.delete(site)
    db.commit()
    return Response(status_code=204)


@router.post("/{company_id}/sources", response_model=SourceOut, status_code=201)
def add_source(company_id: uuid.UUID, body: SourceIn, user: CurrentUser,
               db: DbDep) -> CompanySource:
    get_company(db, user, company_id)
    data = body.model_dump(mode="json")
    src = CompanySource(user_id=user.id, company_id=company_id, **data)
    db.add(src)
    db.commit()
    return src


@router.delete("/{company_id}/sources/{source_id}", status_code=204)
def delete_source(company_id: uuid.UUID, source_id: uuid.UUID, user: CurrentUser,
                  db: DbDep) -> Response:
    src = db.scalar(select(CompanySource).where(
        CompanySource.id == source_id, CompanySource.company_id == company_id,
        CompanySource.user_id == user.id))
    if src is None:
        raise HTTPException(404, "Source not found")
    db.delete(src)
    db.commit()
    return Response(status_code=204)


@router.post("/{company_id}/notes", response_model=NoteOut, status_code=201)
def add_note(company_id: uuid.UUID, body: NoteIn, request: Request, user: CurrentUser,
             db: DbDep) -> CompanyNote:
    get_company(db, user, company_id)
    note = CompanyNote(user_id=user.id, company_id=company_id, body=body.body)
    db.add(note)
    db.flush()
    audit(db, request, user, "company.note_added", "company", company_id)
    db.commit()
    return note


@router.patch("/{company_id}/notes/{note_id}", response_model=NoteOut)
def update_note(company_id: uuid.UUID, note_id: uuid.UUID, body: NoteIn, user: CurrentUser,
                db: DbDep) -> CompanyNote:
    note = _note(db, user, company_id, note_id)
    note.body = body.body
    db.commit()
    db.refresh(note)
    return note


@router.delete("/{company_id}/notes/{note_id}", status_code=204)
def delete_note(company_id: uuid.UUID, note_id: uuid.UUID, user: CurrentUser,
                db: DbDep) -> Response:
    note = _note(db, user, company_id, note_id)
    note.deleted_at = datetime.now(UTC)
    db.commit()
    return Response(status_code=204)


def _note(db: Session, user: User, company_id: uuid.UUID, note_id: uuid.UUID) -> CompanyNote:
    note = db.scalar(select(CompanyNote).where(
        CompanyNote.id == note_id, CompanyNote.company_id == company_id,
        CompanyNote.user_id == user.id, CompanyNote.deleted_at.is_(None)))
    if note is None:
        raise HTTPException(404, "Note not found")
    return note


__all__ = ["router", "company_domains"]
