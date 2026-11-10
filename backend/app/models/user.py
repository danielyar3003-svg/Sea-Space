import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, String, Text, UniqueConstraint, func
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, SoftDeleteMixin, TimestampMixin, uuid_pk


class User(TimestampMixin, SoftDeleteMixin, Base):
    """Application user. Identity lives in Supabase Auth; `auth_subject` is its `sub` claim.

    Passwords are never stored here.
    """

    __tablename__ = "users"

    id: Mapped[uuid.UUID] = uuid_pk()
    auth_subject: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    email: Mapped[str | None] = mapped_column(String(320))
    display_name: Mapped[str | None] = mapped_column(String(200))
    locale: Mapped[str] = mapped_column(String(10), nullable=False, server_default="en")
    consent_terms_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    consent_analytics: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="false")
    last_seen_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class NotificationPreferences(TimestampMixin, Base):
    __tablename__ = "notification_preferences"
    __table_args__ = (UniqueConstraint("user_id"),)

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    push_enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="true")
    notify_email_replies: Mapped[bool] = mapped_column(Boolean, nullable=False,
                                                       server_default="true")
    notify_follow_ups: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="true")
    notify_new_vacancies: Mapped[bool] = mapped_column(Boolean, nullable=False,
                                                       server_default="false")
    quiet_hours_start: Mapped[str | None] = mapped_column(String(5))  # "22:00"
    quiet_hours_end: Mapped[str | None] = mapped_column(String(5))
    timezone: Mapped[str] = mapped_column(String(64), nullable=False, server_default="UTC")
    device_tokens: Mapped[list] = mapped_column(JSONB, nullable=False, server_default="[]")


class AuditLog(Base):
    """Append-only security/audit trail. Never stores message bodies or document content."""

    __tablename__ = "audit_logs"

    id: Mapped[uuid.UUID] = uuid_pk()
    user_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), index=True
    )
    action: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    entity_type: Mapped[str | None] = mapped_column(String(100))
    entity_id: Mapped[str | None] = mapped_column(String(100))
    ip_address: Mapped[str | None] = mapped_column(String(64))
    user_agent: Mapped[str | None] = mapped_column(Text)
    details: Mapped[dict] = mapped_column(JSONB, nullable=False, server_default="{}")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now(), index=True
    )
