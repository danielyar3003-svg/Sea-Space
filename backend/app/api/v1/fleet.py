"""Fleet intelligence: vessels and their owner / operator companies (kept separate)."""

import uuid
from datetime import UTC, datetime
from typing import Annotated

from fastapi import APIRouter, HTTPException, Query, Request, Response, status
from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser, DbDep, audit
from app.models import Company, User, Vessel, VesselOperator, VesselOwner, VesselType
from app.schemas.company import (
    VerifyIn,
    VesselCreate,
    VesselLink,
    VesselLinkIn,
    VesselOut,
    VesselTypeOut,
    VesselUpdate,
)
from app.services.companies import get_company
from app.services.normalize import is_valid_imo

router = APIRouter(tags=["fleet"])


@router.get("/vessel-types", response_model=list[VesselTypeOut])
def list_vessel_types(user: CurrentUser, db: DbDep) -> list[VesselType]:
    return list(db.scalars(select(VesselType).order_by(VesselType.name)))


def _get(db: Session, user: User, vessel_id: uuid.UUID) -> Vessel:
    v = db.scalar(select(Vessel).where(Vessel.id == vessel_id, Vessel.user_id == user.id,
                                       Vessel.deleted_at.is_(None)))
    if v is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Vessel not found")
    return v


def _check_imo(db: Session, user: User, imo: str | None, exclude: uuid.UUID | None = None) -> None:
    if imo is None:
        return
    if not is_valid_imo(imo):
        raise HTTPException(422, "IMO number checksum is invalid")
    clash = db.scalar(select(Vessel).where(Vessel.user_id == user.id, Vessel.imo_number == imo,
                                           Vessel.deleted_at.is_(None), Vessel.id != exclude))
    if clash:
        raise HTTPException(status.HTTP_409_CONFLICT, f"IMO {imo} is already saved as '{clash.name}'")


def _out(db: Session, user: User, v: Vessel) -> VesselOut:
    vtype = db.get(VesselType, v.vessel_type_id) if v.vessel_type_id else None
    links: list[VesselLink] = []
    for model, role in ((VesselOwner, "owner"), (VesselOperator, "operator")):
        for link, cname in db.execute(
                select(model, Company.name).join(Company, Company.id == model.company_id)
                .where(model.vessel_id == v.id, model.user_id == user.id)):
            links.append(VesselLink(
                id=link.id, role=role, vessel_id=v.id, vessel_name=v.name,
                company_id=link.company_id, company_name=cname, valid_from=link.valid_from,
                valid_to=link.valid_to, is_crewing_employer=getattr(link, "is_crewing_employer", None),
                verification_status=link.verification_status, source_url=link.source_url))
    return VesselOut.model_validate(v, from_attributes=True).model_copy(update={
        "vessel_type": VesselTypeOut.model_validate(vtype) if vtype else None,
        "links": links,
        "potential_positions": list(vtype.typical_positions) if vtype else [],
    })


@router.get("/vessels", response_model=list[VesselOut])
def list_vessels(
    user: CurrentUser,
    db: DbDep,
    q: Annotated[str | None, Query(max_length=200)] = None,
    company_id: uuid.UUID | None = None,
    vessel_type_id: uuid.UUID | None = None,
    limit: Annotated[int, Query(ge=1, le=200)] = 100,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> list[VesselOut]:
    stmt = select(Vessel).where(Vessel.user_id == user.id, Vessel.deleted_at.is_(None))
    if q:
        stmt = stmt.where(or_(Vessel.name.ilike(f"%{q}%"), Vessel.imo_number == q.strip()))
    if vessel_type_id:
        stmt = stmt.where(Vessel.vessel_type_id == vessel_type_id)
    if company_id:
        stmt = stmt.where(or_(
            Vessel.id.in_(select(VesselOwner.vessel_id).where(VesselOwner.company_id == company_id)),
            Vessel.id.in_(select(VesselOperator.vessel_id).where(
                VesselOperator.company_id == company_id))))
    return [_out(db, user, v) for v in db.scalars(stmt.order_by(Vessel.name).limit(limit)
                                                   .offset(offset))]


@router.post("/vessels", response_model=VesselOut, status_code=201)
def create_vessel(body: VesselCreate, request: Request, user: CurrentUser, db: DbDep) -> VesselOut:
    _check_imo(db, user, body.imo_number)
    if body.vessel_type_id and db.get(VesselType, body.vessel_type_id) is None:
        raise HTTPException(422, "Unknown vessel type")
    v = Vessel(user_id=user.id, **body.model_dump(exclude={"source_url"}),
               source_url=str(body.source_url) if body.source_url else None,
               verification_status="unverified" if body.source_url else "user_provided")
    db.add(v)
    db.flush()
    audit(db, request, user, "vessel.created", "vessel", v.id)
    db.commit()
    return _out(db, user, v)


@router.get("/vessels/{vessel_id}", response_model=VesselOut)
def get_vessel(vessel_id: uuid.UUID, user: CurrentUser, db: DbDep) -> VesselOut:
    return _out(db, user, _get(db, user, vessel_id))


@router.patch("/vessels/{vessel_id}", response_model=VesselOut)
def update_vessel(vessel_id: uuid.UUID, body: VesselUpdate, request: Request, user: CurrentUser,
                  db: DbDep) -> VesselOut:
    v = _get(db, user, vessel_id)
    changes = body.model_dump(exclude_unset=True)
    if "imo_number" in changes:
        _check_imo(db, user, changes["imo_number"], exclude=v.id)
    for field, value in changes.items():
        setattr(v, field, value)
    audit(db, request, user, "vessel.updated", "vessel", v.id, fields=sorted(changes))
    db.commit()
    return _out(db, user, v)


@router.post("/vessels/{vessel_id}/verify", response_model=VesselOut)
def verify_vessel(vessel_id: uuid.UUID, body: VerifyIn, user: CurrentUser,
                  db: DbDep) -> VesselOut:
    v = _get(db, user, vessel_id)
    v.source_url = str(body.source_url)
    v.last_verified_at = datetime.now(UTC)
    v.verification_status = "verified"
    v.confidence = body.confidence
    db.commit()
    return _out(db, user, v)


@router.delete("/vessels/{vessel_id}", status_code=204)
def delete_vessel(vessel_id: uuid.UUID, request: Request, user: CurrentUser,
                  db: DbDep) -> Response:
    v = _get(db, user, vessel_id)
    v.deleted_at = datetime.now(UTC)
    audit(db, request, user, "vessel.deleted", "vessel", v.id)
    db.commit()
    return Response(status_code=204)


@router.post("/vessels/{vessel_id}/links", response_model=VesselOut, status_code=201)
def add_link(vessel_id: uuid.UUID, body: VesselLinkIn, request: Request, user: CurrentUser,
             db: DbDep) -> VesselOut:
    """Record that a company owns or operates the vessel. Owner and operator are separate
    facts; neither implies the company is the crewing employer."""
    v = _get(db, user, vessel_id)
    get_company(db, user, body.company_id)
    model = VesselOwner if body.role == "owner" else VesselOperator
    exists = db.scalar(select(model).where(model.vessel_id == v.id,
                                           model.company_id == body.company_id,
                                           model.valid_from.is_not_distinct_from(body.valid_from)))
    if exists:
        raise HTTPException(status.HTTP_409_CONFLICT, f"This {body.role} link already exists")
    kwargs = dict(user_id=user.id, vessel_id=v.id, company_id=body.company_id,
                  valid_from=body.valid_from, valid_to=body.valid_to,
                  source_url=str(body.source_url) if body.source_url else None,
                  verification_status="unverified" if body.source_url else "user_provided")
    if body.role == "operator":
        kwargs["is_crewing_employer"] = body.is_crewing_employer
    db.add(model(**kwargs))
    audit(db, request, user, f"vessel.{body.role}_linked", "vessel", v.id,
          company=str(body.company_id))
    db.commit()
    return _out(db, user, v)


@router.delete("/vessels/{vessel_id}/links/{link_id}", status_code=204)
def delete_link(vessel_id: uuid.UUID, link_id: uuid.UUID, user: CurrentUser,
                db: DbDep) -> Response:
    _get(db, user, vessel_id)
    for model in (VesselOwner, VesselOperator):
        link = db.scalar(select(model).where(model.id == link_id, model.vessel_id == vessel_id,
                                             model.user_id == user.id))
        if link:
            db.delete(link)
            db.commit()
            return Response(status_code=204)
    raise HTTPException(404, "Link not found")
