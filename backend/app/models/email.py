"""Gmail mirror. OAuth refresh tokens are stored encrypted (Fernet), never in plain text."""

import uuid
from datetime import datetime

from sqlalchemy import (
    BigInteger,
    Boolean,
    DateTime,
    ForeignKey,
    Index,
    LargeBinary,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, OwnedMixin, TimestampMixin, enum_check, uuid_pk
from app.models.enums import EmailDirection, ThreadAssociation, values


class EmailAccount(OwnedMixin, TimestampMixin, Base):
    __tablename__ = "email_accounts"
    __table_args__ = (
        UniqueConstraint("user_id", "email_address"),
        enum_check("provider", ("gmail",)),
        enum_check("status", ("active", "needs_reauth", "disconnected")),
    )

    id: Mapped[uuid.UUID] = uuid_pk()
    provider: Mapped[str] = mapped_column(String(20), nullable=False, server_default="gmail")
    email_address: Mapped[str] = mapped_column(String(320), nullable=False)
    encrypted_refresh_token: Mapped[bytes | None] = mapped_column(LargeBinary)
    granted_scopes: Mapped[list] = mapped_column(JSONB, nullable=False, server_default="[]")
    history_id: Mapped[int | None] = mapped_column(BigInteger)
    watch_expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), index=True)
    last_synced_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    status: Mapped[str] = mapped_column(String(20), nullable=False, server_default="active")


class EmailThread(OwnedMixin, TimestampMixin, Base):
    __tablename__ = "email_threads"
    __table_args__ = (
        UniqueConstraint("account_id", "provider_thread_id"),
        enum_check("association_status", values(ThreadAssociation)),
    )

    id: Mapped[uuid.UUID] = uuid_pk()
    account_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("email_accounts.id", ondelete="CASCADE"), nullable=False,
        index=True,
    )
    provider_thread_id: Mapped[str] = mapped_column(String(64), nullable=False)
    subject: Mapped[str | None] = mapped_column(Text)
    last_message_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), index=True)
    company_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("companies.id", ondelete="SET NULL"), index=True
    )
    application_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("job_applications.id", ondelete="SET NULL")
    )
    association_status: Mapped[str] = mapped_column(
        String(20), nullable=False, server_default="unlinked"
    )


class EmailMessage(OwnedMixin, TimestampMixin, Base):
    __tablename__ = "email_messages"
    __table_args__ = (
        # Duplicate prevention for history sync / Pub/Sub redelivery.
        UniqueConstraint("account_id", "provider_message_id"),
        enum_check("direction", values(EmailDirection)),
        Index("ix_email_messages_thread_sent", "thread_id", "sent_at"),
    )

    id: Mapped[uuid.UUID] = uuid_pk()
    account_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("email_accounts.id", ondelete="CASCADE"), nullable=False
    )
    thread_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("email_threads.id", ondelete="CASCADE"), nullable=False
    )
    provider_message_id: Mapped[str] = mapped_column(String(64), nullable=False)
    rfc822_message_id: Mapped[str | None] = mapped_column(Text)
    direction: Mapped[str] = mapped_column(String(10), nullable=False)
    from_address: Mapped[str | None] = mapped_column(String(320), index=True)
    to_addresses: Mapped[list] = mapped_column(JSONB, nullable=False, server_default="[]")
    cc_addresses: Mapped[list] = mapped_column(JSONB, nullable=False, server_default="[]")
    bcc_addresses: Mapped[list] = mapped_column(JSONB, nullable=False, server_default="[]")
    subject: Mapped[str | None] = mapped_column(Text)
    snippet: Mapped[str | None] = mapped_column(Text)
    body_text: Mapped[str | None] = mapped_column(Text)
    labels: Mapped[list] = mapped_column(JSONB, nullable=False, server_default="[]")
    is_draft: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="false")
    sent_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class EmailAttachment(OwnedMixin, TimestampMixin, Base):
    __tablename__ = "email_attachments"

    id: Mapped[uuid.UUID] = uuid_pk()
    message_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("email_messages.id", ondelete="CASCADE"), nullable=False,
        index=True,
    )
    filename: Mapped[str] = mapped_column(String(500), nullable=False)
    mime_type: Mapped[str | None] = mapped_column(String(200))
    size_bytes: Mapped[int | None] = mapped_column(BigInteger)
    provider_attachment_id: Mapped[str | None] = mapped_column(Text)
    document_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("candidate_documents.id", ondelete="SET NULL")
    )
