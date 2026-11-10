import uuid
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

from app.models.enums import ApplicationStatus


class ApplicationCreate(BaseModel):
    company_id: uuid.UUID
    position: str | None = Field(default=None, max_length=200)
    status: ApplicationStatus = ApplicationStatus.DISCOVERED
    vacancy_id: uuid.UUID | None = None
    contact_id: uuid.UUID | None = None
    profile_id: uuid.UUID | None = None
    notes: str | None = Field(default=None, max_length=10000)


class ApplicationUpdate(BaseModel):
    position: str | None = Field(default=None, max_length=200)
    status: ApplicationStatus | None = None
    vacancy_id: uuid.UUID | None = None
    contact_id: uuid.UUID | None = None
    profile_id: uuid.UUID | None = None
    notes: str | None = Field(default=None, max_length=10000)
    # Recorded in the status history together with a status change.
    status_note: str | None = Field(default=None, max_length=2000)
    # Convenience: create a follow-up reminder N days from now with this change.
    follow_up_in_days: int | None = Field(default=None, ge=1, le=365)
    # Title for that reminder, in the user's language (the app sends it).
    follow_up_title: str | None = Field(default=None, min_length=1, max_length=300)


class StatusChange(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    from_status: str | None
    to_status: str
    note: str | None
    changed_at: datetime


class FollowUpIn(BaseModel):
    title: str = Field(min_length=1, max_length=300)
    due_at: datetime
    application_id: uuid.UUID | None = None
    company_id: uuid.UUID | None = None


class FollowUpUpdate(BaseModel):
    title: str | None = Field(default=None, min_length=1, max_length=300)
    due_at: datetime | None = None
    completed: bool | None = None


class FollowUpOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    title: str
    due_at: datetime
    completed_at: datetime | None
    application_id: uuid.UUID | None
    company_id: uuid.UUID | None
    company_name: str | None = None
    overdue: bool = False


class ApplicationOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    company_id: uuid.UUID
    company_name: str
    position: str | None
    status: ApplicationStatus
    vacancy_id: uuid.UUID | None
    contact_id: uuid.UUID | None
    contact_name: str | None = None
    profile_id: uuid.UUID | None
    notes: str | None
    sent_at: datetime | None
    last_reply_at: datetime | None
    next_follow_up_at: datetime | None
    created_at: datetime
    updated_at: datetime


class ApplicationDetail(ApplicationOut):
    history: list[StatusChange] = []
    follow_ups: list[FollowUpOut] = []


class BoardColumn(BaseModel):
    status: ApplicationStatus
    applications: list[ApplicationOut]


class PipelineStats(BaseModel):
    total: int
    by_status: dict[str, int]
    sent: int
    replied: int
    reply_rate: float | None = Field(description="Replies / sent, null when nothing was sent")
    interviews: int
    offers: int
    hired: int
    open_follow_ups: int
    overdue_follow_ups: int
    median_days_to_reply: float | None


class TimelineEvent(BaseModel):
    at: datetime
    kind: Literal["company_added", "note", "contact_added", "application_created", "status_changed",
                  "follow_up_created", "follow_up_done", "vacancy_added", "source_added"]
    title: str
    detail: str | None = None
    application_id: uuid.UUID | None = None
