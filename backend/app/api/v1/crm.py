"""Recruitment CRM: application pipeline, status history, follow-ups, company timeline, stats."""

import statistics
import uuid
from datetime import UTC, datetime, timedelta
from typing import Annotated, Literal

from fastapi import APIRouter, HTTPException, Query, Request, Response, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.api.deps import CurrentUser, DbDep, audit
from app.models import (
    ApplicationStatusHistory,
    Company,
    CompanyContact,
    CompanyNote,
    CompanySource,
    FollowUpTask,
    JobApplication,
    User,
    Vacancy,
)
from app.models.enums import ApplicationStatus as S
from app.schemas.crm import (
    ApplicationCreate,
    ApplicationDetail,
    ApplicationOut,
    ApplicationUpdate,
    BoardColumn,
    FollowUpIn,
    FollowUpOut,
    FollowUpUpdate,
    PipelineStats,
    StatusChange,
    TimelineEvent,
)
from app.services.companies import get_company

router = APIRouter(tags=["crm"])

SENT_OR_LATER = {S.SENT, S.WAITING_FOR_REPLY, S.FOLLOW_UP_NEEDED, S.REPLIED, S.INTERVIEW, S.OFFER,
                 S.HIRED, S.REJECTED, S.NO_VACANCIES, S.KEEP_IN_TOUCH}
REPLY_STATUSES = {S.REPLIED, S.INTERVIEW, S.OFFER, S.HIRED, S.REJECTED, S.NO_VACANCIES}


def _now() -> datetime:
    return datetime.now(UTC)


def _get_app(db: Session, user: User, app_id: uuid.UUID) -> JobApplication:
    a = db.scalar(select(JobApplication).where(JobApplication.id == app_id,
                                               JobApplication.user_id == user.id,
                                               JobApplication.deleted_at.is_(None)))
    if a is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Application not found")
    return a


def _check_links(db: Session, user: User, company_id: uuid.UUID, contact_id: uuid.UUID | None,
                 vacancy_id: uuid.UUID | None) -> None:
    if contact_id and not db.scalar(select(CompanyContact.id).where(
            CompanyContact.id == contact_id, CompanyContact.user_id == user.id,
            CompanyContact.company_id == company_id, CompanyContact.deleted_at.is_(None))):
        raise HTTPException(422, "The contact does not belong to this company")
    if vacancy_id and not db.scalar(select(Vacancy.id).where(
            Vacancy.id == vacancy_id, Vacancy.user_id == user.id, Vacancy.deleted_at.is_(None))):
        raise HTTPException(422, "Unknown vacancy")


def _refresh_next_follow_up(db: Session, a: JobApplication) -> None:
    db.flush()
    a.next_follow_up_at = db.scalar(select(func.min(FollowUpTask.due_at)).where(
        FollowUpTask.application_id == a.id, FollowUpTask.completed_at.is_(None),
        FollowUpTask.deleted_at.is_(None)))


def _apply_status(db: Session, user: User, a: JobApplication, new: str, note: str | None) -> None:
    if new == a.status:
        return
    db.add(ApplicationStatusHistory(user_id=user.id, application_id=a.id, from_status=a.status,
                                    to_status=new, note=note))
    a.status = new
    if new in SENT_OR_LATER and a.sent_at is None:
        a.sent_at = _now()
    if new in REPLY_STATUSES and a.last_reply_at is None:
        a.last_reply_at = _now()


def _outs(db: Session, user: User, apps: list[JobApplication]) -> list[ApplicationOut]:
    if not apps:
        return []
    names = dict(db.execute(select(Company.id, Company.name).where(
        Company.id.in_({a.company_id for a in apps}))).all())
    contact_ids = {a.contact_id for a in apps if a.contact_id}
    contacts = {}
    if contact_ids:
        for c in db.scalars(select(CompanyContact).where(CompanyContact.id.in_(contact_ids))):
            contacts[c.id] = c.full_name or c.email
    fields = [f for f in ApplicationOut.model_fields if f not in ("company_name", "contact_name")]
    return [
        ApplicationOut(**{f: getattr(a, f) for f in fields},
                       company_name=names.get(a.company_id, ""),
                       contact_name=contacts.get(a.contact_id))
        for a in apps
    ]


def _follow_out(f: FollowUpTask, company_name: str | None = None) -> FollowUpOut:
    return FollowUpOut.model_validate(f).model_copy(update={
        "company_name": company_name,
        "overdue": f.completed_at is None and f.due_at < _now(),
    })


def _detail(db: Session, user: User, a: JobApplication) -> ApplicationDetail:
    base = _outs(db, user, [a])[0]
    history = db.scalars(select(ApplicationStatusHistory).where(
        ApplicationStatusHistory.application_id == a.id)
        .order_by(ApplicationStatusHistory.changed_at.desc())).all()
    follow = db.scalars(select(FollowUpTask).where(
        FollowUpTask.application_id == a.id, FollowUpTask.deleted_at.is_(None))
        .order_by(FollowUpTask.completed_at.is_not(None), FollowUpTask.due_at)).all()
    return ApplicationDetail(**base.model_dump(),
                             history=[StatusChange.model_validate(h) for h in history],
                             follow_ups=[_follow_out(f, base.company_name) for f in follow])


# --- Applications ---------------------------------------------------------------------------


@router.get("/applications", response_model=list[ApplicationOut])
def list_applications(
    user: CurrentUser, db: DbDep,
    status_: Annotated[S | None, Query(alias="status")] = None,
    company_id: uuid.UUID | None = None,
    q: Annotated[str | None, Query(max_length=200)] = None,
) -> list[ApplicationOut]:
    stmt = (select(JobApplication).join(Company, Company.id == JobApplication.company_id)
            .where(JobApplication.user_id == user.id, JobApplication.deleted_at.is_(None),
                   Company.deleted_at.is_(None)))
    if status_:
        stmt = stmt.where(JobApplication.status == status_)
    if company_id:
        stmt = stmt.where(JobApplication.company_id == company_id)
    if q:
        stmt = stmt.where(Company.name.ilike(f"%{q}%") | JobApplication.position.ilike(f"%{q}%"))
    return _outs(db, user, list(db.scalars(stmt.order_by(JobApplication.updated_at.desc()))))


@router.get("/applications/board", response_model=list[BoardColumn])
def board(user: CurrentUser, db: DbDep) -> list[BoardColumn]:
    """Kanban columns in pipeline order; every status is present even when empty."""
    apps = list_applications(user, db)
    return [BoardColumn(status=s, applications=[a for a in apps if a.status == s]) for s in S]


@router.get("/applications/stats", response_model=PipelineStats)
def stats(user: CurrentUser, db: DbDep) -> PipelineStats:
    apps = db.scalars(select(JobApplication).where(JobApplication.user_id == user.id,
                                                   JobApplication.deleted_at.is_(None))).all()
    by_status = {s.value: 0 for s in S}
    for a in apps:
        by_status[a.status] += 1
    sent = [a for a in apps if a.sent_at is not None]
    replied = [a for a in sent if a.last_reply_at is not None]
    days = [(a.last_reply_at - a.sent_at).total_seconds() / 86400 for a in replied
            if a.last_reply_at >= a.sent_at]
    open_f = db.scalars(select(FollowUpTask).where(
        FollowUpTask.user_id == user.id, FollowUpTask.completed_at.is_(None),
        FollowUpTask.deleted_at.is_(None))).all()
    return PipelineStats(
        total=len(apps), by_status=by_status, sent=len(sent), replied=len(replied),
        reply_rate=round(len(replied) / len(sent), 3) if sent else None,
        interviews=by_status[S.INTERVIEW], offers=by_status[S.OFFER], hired=by_status[S.HIRED],
        open_follow_ups=len(open_f), overdue_follow_ups=sum(f.due_at < _now() for f in open_f),
        median_days_to_reply=round(statistics.median(days), 1) if days else None,
    )


@router.post("/applications", response_model=ApplicationDetail, status_code=201)
def create_application(body: ApplicationCreate, request: Request, user: CurrentUser,
                       db: DbDep) -> ApplicationDetail:
    get_company(db, user, body.company_id)
    _check_links(db, user, body.company_id, body.contact_id, body.vacancy_id)
    a = JobApplication(user_id=user.id, **body.model_dump(exclude={"status"}), status=S.DISCOVERED)
    db.add(a)
    db.flush()
    db.add(ApplicationStatusHistory(user_id=user.id, application_id=a.id, from_status=None,
                                    to_status=S.DISCOVERED, note="Created"))
    if body.status != S.DISCOVERED:
        _apply_status(db, user, a, body.status, None)
    audit(db, request, user, "application.created", "application", a.id)
    db.commit()
    return _detail(db, user, a)


@router.get("/applications/{app_id}", response_model=ApplicationDetail)
def get_application(app_id: uuid.UUID, user: CurrentUser, db: DbDep) -> ApplicationDetail:
    return _detail(db, user, _get_app(db, user, app_id))


@router.patch("/applications/{app_id}", response_model=ApplicationDetail)
def update_application(app_id: uuid.UUID, body: ApplicationUpdate, request: Request,
                       user: CurrentUser, db: DbDep) -> ApplicationDetail:
    a = _get_app(db, user, app_id)
    changes = body.model_dump(exclude_unset=True)
    new_status = changes.pop("status", None)
    note = changes.pop("status_note", None)
    days = changes.pop("follow_up_in_days", None)
    follow_title = changes.pop("follow_up_title", None)
    _check_links(db, user, a.company_id, changes.get("contact_id"), changes.get("vacancy_id"))
    for field, value in changes.items():
        setattr(a, field, value)
    if new_status:
        _apply_status(db, user, a, new_status, note)
    if days:
        db.add(FollowUpTask(user_id=user.id, application_id=a.id, company_id=a.company_id,
                            title=follow_title or "Follow up on application",
                            due_at=_now() + timedelta(days=days)))
    _refresh_next_follow_up(db, a)
    audit(db, request, user, "application.updated", "application", a.id,
          status=new_status, fields=sorted(changes))
    db.commit()
    return _detail(db, user, a)


@router.delete("/applications/{app_id}", status_code=204)
def delete_application(app_id: uuid.UUID, request: Request, user: CurrentUser,
                       db: DbDep) -> Response:
    a = _get_app(db, user, app_id)
    a.deleted_at = _now()
    audit(db, request, user, "application.deleted", "application", a.id)
    db.commit()
    return Response(status_code=204)


# --- Follow-ups -----------------------------------------------------------------------------


@router.get("/follow-ups", response_model=list[FollowUpOut])
def list_follow_ups(
    user: CurrentUser, db: DbDep,
    state: Literal["open", "overdue", "done", "all"] = "open",
    application_id: uuid.UUID | None = None,
    company_id: uuid.UUID | None = None,
) -> list[FollowUpOut]:
    stmt = (select(FollowUpTask, Company.name)
            .outerjoin(Company, Company.id == FollowUpTask.company_id)
            .where(FollowUpTask.user_id == user.id, FollowUpTask.deleted_at.is_(None)))
    if state == "open":
        stmt = stmt.where(FollowUpTask.completed_at.is_(None))
    elif state == "overdue":
        stmt = stmt.where(FollowUpTask.completed_at.is_(None), FollowUpTask.due_at < _now())
    elif state == "done":
        stmt = stmt.where(FollowUpTask.completed_at.is_not(None))
    if application_id:
        stmt = stmt.where(FollowUpTask.application_id == application_id)
    if company_id:
        stmt = stmt.where(FollowUpTask.company_id == company_id)
    return [_follow_out(f, n) for f, n in db.execute(stmt.order_by(FollowUpTask.due_at))]


def _sync_app(db: Session, user: User, application_id: uuid.UUID | None) -> None:
    if application_id:
        a = db.scalar(select(JobApplication).where(JobApplication.id == application_id,
                                                   JobApplication.user_id == user.id))
        if a:
            _refresh_next_follow_up(db, a)


@router.post("/follow-ups", response_model=FollowUpOut, status_code=201)
def create_follow_up(body: FollowUpIn, user: CurrentUser, db: DbDep) -> FollowUpOut:
    company_id = body.company_id
    if body.application_id:
        company_id = _get_app(db, user, body.application_id).company_id
    if company_id is None:
        raise HTTPException(422, "A follow-up belongs to a company or an application")
    company = get_company(db, user, company_id)
    f = FollowUpTask(user_id=user.id, application_id=body.application_id, company_id=company_id,
                     title=body.title, due_at=body.due_at)
    db.add(f)
    _sync_app(db, user, body.application_id)
    db.commit()
    return _follow_out(f, company.name)


@router.patch("/follow-ups/{follow_up_id}", response_model=FollowUpOut)
def update_follow_up(follow_up_id: uuid.UUID, body: FollowUpUpdate, user: CurrentUser,
                     db: DbDep) -> FollowUpOut:
    f = db.scalar(select(FollowUpTask).where(FollowUpTask.id == follow_up_id,
                                             FollowUpTask.user_id == user.id,
                                             FollowUpTask.deleted_at.is_(None)))
    if f is None:
        raise HTTPException(404, "Follow-up not found")
    changes = body.model_dump(exclude_unset=True)
    if "completed" in changes:
        f.completed_at = _now() if changes.pop("completed") else None
    for field, value in changes.items():
        setattr(f, field, value)
    _sync_app(db, user, f.application_id)
    db.commit()
    name = db.scalar(select(Company.name).where(Company.id == f.company_id))
    return _follow_out(f, name)


@router.delete("/follow-ups/{follow_up_id}", status_code=204)
def delete_follow_up(follow_up_id: uuid.UUID, user: CurrentUser, db: DbDep) -> Response:
    f = db.scalar(select(FollowUpTask).where(FollowUpTask.id == follow_up_id,
                                             FollowUpTask.user_id == user.id,
                                             FollowUpTask.deleted_at.is_(None)))
    if f is None:
        raise HTTPException(404, "Follow-up not found")
    f.deleted_at = _now()
    _sync_app(db, user, f.application_id)
    db.commit()
    return Response(status_code=204)


# --- Company timeline -----------------------------------------------------------------------


@router.get("/companies/{company_id}/timeline", response_model=list[TimelineEvent])
def company_timeline(company_id: uuid.UUID, user: CurrentUser, db: DbDep) -> list[TimelineEvent]:
    """Everything that happened with this employer, newest first, built from the records."""
    c: Company = get_company(db, user, company_id)
    ev: list[TimelineEvent] = [TimelineEvent(at=c.created_at, kind="company_added", title=c.name)]
    uid = user.id
    for n in db.scalars(select(CompanyNote).where(CompanyNote.company_id == c.id,
                                                  CompanyNote.user_id == uid,
                                                  CompanyNote.deleted_at.is_(None))):
        ev.append(TimelineEvent(at=n.created_at, kind="note", title=n.body[:200]))
    for ct in db.scalars(select(CompanyContact).where(CompanyContact.company_id == c.id,
                                                      CompanyContact.user_id == uid,
                                                      CompanyContact.deleted_at.is_(None))):
        ev.append(TimelineEvent(at=ct.created_at, kind="contact_added",
                                title=ct.full_name or ct.email or "Contact", detail=ct.job_title))
    for s in db.scalars(select(CompanySource).where(CompanySource.company_id == c.id,
                                                    CompanySource.user_id == uid)):
        ev.append(TimelineEvent(at=s.retrieved_at, kind="source_added",
                                title=s.title or s.source_type, detail=s.url))
    for v in db.scalars(select(Vacancy).where(Vacancy.company_id == c.id, Vacancy.user_id == uid,
                                              Vacancy.deleted_at.is_(None))):
        ev.append(TimelineEvent(at=v.discovered_at, kind="vacancy_added", title=v.position,
                                detail=v.source_url))
    apps = db.scalars(select(JobApplication).where(JobApplication.company_id == c.id,
                                                   JobApplication.user_id == uid,
                                                   JobApplication.deleted_at.is_(None))).all()
    for a in apps:
        for h in db.scalars(select(ApplicationStatusHistory).where(
                ApplicationStatusHistory.application_id == a.id)):
            if h.from_status is None:
                ev.append(TimelineEvent(at=h.changed_at, kind="application_created",
                                        title=a.position or "Application", application_id=a.id))
            else:
                ev.append(TimelineEvent(at=h.changed_at, kind="status_changed", title=h.to_status,
                                        detail=h.note, application_id=a.id))
    for f in db.scalars(select(FollowUpTask).where(FollowUpTask.company_id == c.id,
                                                   FollowUpTask.user_id == uid,
                                                   FollowUpTask.deleted_at.is_(None))):
        ev.append(TimelineEvent(at=f.created_at, kind="follow_up_created", title=f.title,
                                detail=f.due_at.isoformat(), application_id=f.application_id))
        if f.completed_at:
            ev.append(TimelineEvent(at=f.completed_at, kind="follow_up_done", title=f.title,
                                    application_id=f.application_id))
    return sorted(ev, key=lambda e: e.at, reverse=True)
