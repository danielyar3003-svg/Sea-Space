"""Vacancies. New entries are `unverified`; only the user checking the source page makes one
`active`. Past deadlines are reported as `expired` automatically."""

import uuid
from datetime import UTC, date, datetime
from typing import Annotated

from fastapi import APIRouter, HTTPException, Query, Request, Response, status
from sqlalchemy import or_, select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser, DbDep, audit
from app.models import User, Vacancy
from app.models.enums import VacancyStatus
from app.schemas.company import VacancyCreate, VacancyOut, VacancyUpdate
from app.services.companies import get_company

router = APIRouter(prefix="/vacancies", tags=["vacancies"])


def _expire_past_deadlines(db: Session, user: User) -> None:
    db.execute(update(Vacancy).where(
        Vacancy.user_id == user.id, Vacancy.status != "expired",
        Vacancy.application_deadline < date.today()).values(status="expired"))


def _get(db: Session, user: User, vacancy_id: uuid.UUID) -> Vacancy:
    v = db.scalar(select(Vacancy).where(Vacancy.id == vacancy_id, Vacancy.user_id == user.id,
                                        Vacancy.deleted_at.is_(None)))
    if v is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Vacancy not found")
    return v


def _check_salary(min_: object, max_: object) -> None:
    if min_ is not None and max_ is not None and max_ < min_:
        raise HTTPException(422, "salary_max must not be below salary_min")


@router.get("", response_model=list[VacancyOut])
def list_vacancies(
    user: CurrentUser,
    db: DbDep,
    status_: Annotated[VacancyStatus | None, Query(alias="status")] = None,
    q: Annotated[str | None, Query(max_length=200)] = None,
    country: Annotated[str | None, Query(min_length=2, max_length=2)] = None,
    company_id: uuid.UUID | None = None,
    limit: Annotated[int, Query(ge=1, le=200)] = 100,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> list[Vacancy]:
    _expire_past_deadlines(db, user)
    db.commit()
    stmt = select(Vacancy).where(Vacancy.user_id == user.id, Vacancy.deleted_at.is_(None))
    if status_:
        stmt = stmt.where(Vacancy.status == status_)
    if q:
        like = f"%{q}%"
        stmt = stmt.where(or_(Vacancy.position.ilike(like), Vacancy.employer_name.ilike(like),
                              Vacancy.vessel_type.ilike(like)))
    if country:
        stmt = stmt.where(Vacancy.country_code == country.upper())
    if company_id:
        stmt = stmt.where(Vacancy.company_id == company_id)
    return list(db.scalars(stmt.order_by(Vacancy.discovered_at.desc()).limit(limit).offset(offset)))


@router.post("", response_model=VacancyOut, status_code=201)
def create_vacancy(body: VacancyCreate, request: Request, user: CurrentUser,
                   db: DbDep) -> Vacancy:
    _check_salary(body.salary_min, body.salary_max)
    if body.company_id:
        get_company(db, user, body.company_id)
    v = Vacancy(user_id=user.id, **body.model_dump(mode="json"), status="unverified")
    db.add(v)
    try:
        db.flush()
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(status.HTTP_409_CONFLICT,
                            "A vacancy with this source URL is already saved") from exc
    audit(db, request, user, "vacancy.created", "vacancy", v.id)
    db.commit()
    return v


@router.patch("/{vacancy_id}", response_model=VacancyOut)
def update_vacancy(vacancy_id: uuid.UUID, body: VacancyUpdate, user: CurrentUser,
                   db: DbDep) -> Vacancy:
    v = _get(db, user, vacancy_id)
    changes = body.model_dump(exclude_unset=True, mode="json")
    if changes.get("company_id"):
        get_company(db, user, uuid.UUID(changes["company_id"]))
    for field, value in changes.items():
        setattr(v, field, value)
    _check_salary(v.salary_min if "salary_min" not in changes else body.salary_min,
                  v.salary_max if "salary_max" not in changes else body.salary_max)
    db.commit()
    db.refresh(v)
    return v


@router.post("/{vacancy_id}/verify", response_model=VacancyOut)
def verify_vacancy(vacancy_id: uuid.UUID, request: Request, user: CurrentUser,
                   db: DbDep) -> Vacancy:
    """The user opened the source page and confirmed the posting is still open."""
    v = _get(db, user, vacancy_id)
    if v.application_deadline and v.application_deadline < date.today():
        raise HTTPException(422, "The application deadline has passed")
    v.status = "active"
    v.last_verified_at = datetime.now(UTC)
    audit(db, request, user, "vacancy.verified", "vacancy", v.id)
    db.commit()
    db.refresh(v)
    return v


@router.delete("/{vacancy_id}", status_code=204)
def delete_vacancy(vacancy_id: uuid.UUID, user: CurrentUser, db: DbDep) -> Response:
    v = _get(db, user, vacancy_id)
    v.deleted_at = datetime.now(UTC)
    db.commit()
    return Response(status_code=204)
