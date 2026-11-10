"""HR / recruitment contacts.

Rules enforced here and in the database:
* an inferred (guessed) e-mail can never be marked verified;
* `verified` is set only via /verify with the source the user checked;
* generic inboxes (jobs@, crew@…) are kept apart from named people.
"""

import uuid
from datetime import UTC, datetime
from typing import Annotated, Literal

from fastapi import APIRouter, HTTPException, Query, Request, Response, status
from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser, DbDep, audit
from app.models import Company, CompanyContact, ContactSource, User
from app.schemas.company import ContactCreate, ContactOut, ContactUpdate, VerifyIn
from app.services.companies import company_domains, get_company
from app.services.normalize import email_domain

router = APIRouter(tags=["contacts"])


def _out(db: Session, user: User, contact: CompanyContact, company: Company | None = None,
         domains: set[str] | None = None) -> ContactOut:
    company = company or db.get(Company, contact.company_id)
    if domains is None and company is not None:
        domains = company_domains(db, user, company)
    edomain = email_domain(contact.email)
    matches = None if not (edomain and domains) else edomain in domains
    return ContactOut.model_validate(contact, from_attributes=True).model_copy(update={
        "company_name": company.name if company else None,
        "domain_matches_company": matches,
    })


def _get(db: Session, user: User, contact_id: uuid.UUID) -> CompanyContact:
    contact = db.scalar(select(CompanyContact).where(
        CompanyContact.id == contact_id, CompanyContact.user_id == user.id,
        CompanyContact.deleted_at.is_(None)))
    if contact is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Contact not found")
    return contact


@router.get("/contacts", response_model=list[ContactOut])
def list_contacts(
    user: CurrentUser,
    db: DbDep,
    filter: Literal["all", "verified", "unverified", "generic", "people", "inferred"] = "all",
    q: Annotated[str | None, Query(max_length=200)] = None,
    company_id: uuid.UUID | None = None,
    limit: Annotated[int, Query(ge=1, le=200)] = 100,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> list[ContactOut]:
    stmt = (select(CompanyContact, Company)
            .join(Company, Company.id == CompanyContact.company_id)
            .where(CompanyContact.user_id == user.id, CompanyContact.deleted_at.is_(None),
                   Company.deleted_at.is_(None)))
    match filter:
        case "verified":
            stmt = stmt.where(CompanyContact.verification_status == "verified")
        case "unverified":
            stmt = stmt.where(CompanyContact.verification_status != "verified")
        case "generic":
            stmt = stmt.where(CompanyContact.contact_kind == "generic_inbox")
        case "people":
            stmt = stmt.where(CompanyContact.contact_kind == "person")
        case "inferred":
            stmt = stmt.where(CompanyContact.email_status == "inferred")
    if company_id:
        stmt = stmt.where(CompanyContact.company_id == company_id)
    if q:
        like = f"%{q}%"
        stmt = stmt.where(or_(CompanyContact.full_name.ilike(like),
                              CompanyContact.job_title.ilike(like),
                              CompanyContact.email.ilike(like), Company.name.ilike(like)))
    rows = db.execute(stmt.order_by(Company.name, CompanyContact.full_name)
                      .limit(limit).offset(offset)).all()
    domain_cache: dict[uuid.UUID, set[str]] = {}
    out = []
    for contact, company in rows:
        if company.id not in domain_cache:
            domain_cache[company.id] = company_domains(db, user, company)
        out.append(_out(db, user, contact, company, domain_cache[company.id]))
    return out


@router.post("/companies/{company_id}/contacts", response_model=ContactOut, status_code=201)
def create_contact(company_id: uuid.UUID, body: ContactCreate, request: Request,
                   user: CurrentUser, db: DbDep) -> ContactOut:
    company = get_company(db, user, company_id)
    if body.email and db.scalar(select(CompanyContact).where(
            CompanyContact.user_id == user.id, CompanyContact.company_id == company.id,
            CompanyContact.email == str(body.email), CompanyContact.deleted_at.is_(None))):
        raise HTTPException(status.HTTP_409_CONFLICT, "This e-mail is already saved for the company")
    data = body.model_dump(exclude={"source_url"}, mode="json")
    if data.get("email") and not data.get("email_status"):
        data["email_status"] = "public_unverified" if body.source_url else "user_provided"
    contact = CompanyContact(
        user_id=user.id, company_id=company.id, **data,
        source_url=str(body.source_url) if body.source_url else None,
        verification_status="unverified" if body.source_url else "user_provided",
    )
    db.add(contact)
    db.flush()
    if body.source_url:
        db.add(ContactSource(user_id=user.id, contact_id=contact.id, url=str(body.source_url)))
    audit(db, request, user, "contact.created", "contact", contact.id)
    db.commit()
    return _out(db, user, contact, company)


@router.patch("/contacts/{contact_id}", response_model=ContactOut)
def update_contact(contact_id: uuid.UUID, body: ContactUpdate, request: Request,
                   user: CurrentUser, db: DbDep) -> ContactOut:
    contact = _get(db, user, contact_id)
    changes = body.model_dump(exclude_unset=True, mode="json")
    if "email" in changes and changes["email"] != contact.email:
        # A changed address is no longer the one that was verified.
        if contact.verification_status == "verified":
            contact.verification_status = "unverified"
        if "email_status" not in changes:
            changes["email_status"] = "user_provided"
    if changes.get("email_status") == "inferred" and contact.verification_status == "verified":
        contact.verification_status = "inferred"
    for field, value in changes.items():
        setattr(contact, field, value)
    audit(db, request, user, "contact.updated", "contact", contact.id, fields=sorted(changes))
    db.commit()
    return _out(db, user, contact)


@router.post("/contacts/{contact_id}/verify", response_model=ContactOut)
def verify_contact(contact_id: uuid.UUID, body: VerifyIn, request: Request, user: CurrentUser,
                   db: DbDep) -> ContactOut:
    contact = _get(db, user, contact_id)
    if contact.email_status == "inferred":
        raise HTTPException(422,
                            "An inferred e-mail cannot be verified. Replace it with the address "
                            "published on the source page first.")
    now = datetime.now(UTC)
    contact.source_url = str(body.source_url)
    contact.last_verified_at = now
    contact.verification_status = "verified"
    contact.confidence = body.confidence
    if contact.email:
        contact.email_status = "public_verified"
    db.add(ContactSource(user_id=user.id, contact_id=contact.id, url=str(body.source_url),
                         retrieved_at=now))
    audit(db, request, user, "contact.verified", "contact", contact.id)
    db.commit()
    return _out(db, user, contact)


@router.delete("/contacts/{contact_id}", status_code=204)
def delete_contact(contact_id: uuid.UUID, request: Request, user: CurrentUser,
                   db: DbDep) -> Response:
    contact = _get(db, user, contact_id)
    contact.deleted_at = datetime.now(UTC)
    audit(db, request, user, "contact.deleted", "contact", contact.id)
    db.commit()
    return Response(status_code=204)
