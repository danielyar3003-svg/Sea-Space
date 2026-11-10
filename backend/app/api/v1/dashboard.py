"""Home dashboard. Every number is a live COUNT over the user's own rows — nothing is seeded."""

import uuid
from datetime import datetime

from fastapi import APIRouter
from pydantic import BaseModel
from sqlalchemy import func, select

from app.api.deps import CurrentUser, DbDep
from app.models import AuditLog, Company, CompanyContact, FollowUpTask, JobApplication
from app.models.enums import ApplicationStatus as S

router = APIRouter(prefix="/dashboard", tags=["dashboard"])

NOT_YET_SENT = (S.DISCOVERED, S.RESEARCHED, S.READY_TO_CONTACT, S.DRAFT_CREATED)


class DashboardCounts(BaseModel):
    companies: int
    verified_contacts: int
    applications_sent: int
    replies_received: int
    pending_follow_ups: int
    interviews: int
    offers: int


class FollowUpItem(BaseModel):
    id: uuid.UUID
    title: str
    due_at: datetime
    company_id: uuid.UUID | None


class CompanyItem(BaseModel):
    id: uuid.UUID
    name: str
    country_code: str | None
    hiring_status: str
    created_at: datetime


class ActivityItem(BaseModel):
    action: str
    entity_type: str | None
    created_at: datetime


class DashboardSummary(BaseModel):
    counts: DashboardCounts
    upcoming_follow_ups: list[FollowUpItem]
    new_companies: list[CompanyItem]
    recent_activity: list[ActivityItem]


@router.get("/summary", response_model=DashboardSummary)
def dashboard_summary(user: CurrentUser, db: DbDep) -> DashboardSummary:
    uid = user.id
    live_apps = (JobApplication.user_id == uid, JobApplication.deleted_at.is_(None))

    def count(stmt) -> int:  # noqa: ANN001
        return int(db.scalar(stmt) or 0)

    counts = DashboardCounts(
        companies=count(select(func.count()).select_from(Company).where(
            Company.user_id == uid, Company.deleted_at.is_(None),
            Company.merged_into_id.is_(None))),
        verified_contacts=count(select(func.count()).select_from(CompanyContact).where(
            CompanyContact.user_id == uid, CompanyContact.deleted_at.is_(None),
            CompanyContact.verification_status == "verified")),
        applications_sent=count(select(func.count()).select_from(JobApplication).where(
            *live_apps, JobApplication.status.not_in([s.value for s in NOT_YET_SENT]))),
        replies_received=count(select(func.count()).select_from(JobApplication).where(
            *live_apps, JobApplication.last_reply_at.is_not(None))),
        pending_follow_ups=count(select(func.count()).select_from(FollowUpTask).where(
            FollowUpTask.user_id == uid, FollowUpTask.deleted_at.is_(None),
            FollowUpTask.completed_at.is_(None))),
        interviews=count(select(func.count()).select_from(JobApplication).where(
            *live_apps, JobApplication.status == S.INTERVIEW)),
        offers=count(select(func.count()).select_from(JobApplication).where(
            *live_apps, JobApplication.status == S.OFFER)),
    )

    follow_ups = db.scalars(
        select(FollowUpTask).where(
            FollowUpTask.user_id == uid, FollowUpTask.deleted_at.is_(None),
            FollowUpTask.completed_at.is_(None))
        .order_by(FollowUpTask.due_at).limit(5)
    )
    companies = db.scalars(
        select(Company).where(Company.user_id == uid, Company.deleted_at.is_(None))
        .order_by(Company.created_at.desc()).limit(5)
    )
    activity = db.scalars(
        select(AuditLog).where(AuditLog.user_id == uid)
        .order_by(AuditLog.created_at.desc()).limit(10)
    )
    return DashboardSummary(
        counts=counts,
        upcoming_follow_ups=[FollowUpItem(id=f.id, title=f.title, due_at=f.due_at,
                                          company_id=f.company_id) for f in follow_ups],
        new_companies=[CompanyItem(id=c.id, name=c.name, country_code=c.country_code,
                                   hiring_status=c.hiring_status, created_at=c.created_at)
                       for c in companies],
        recent_activity=[ActivityItem(action=a.action, entity_type=a.entity_type,
                                      created_at=a.created_at) for a in activity],
    )
