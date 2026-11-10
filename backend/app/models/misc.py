"""Salary data, AI artefacts and search history."""

import uuid
from datetime import date, datetime
from decimal import Decimal

from sqlalchemy import Boolean, Date, DateTime, ForeignKey, Integer, Numeric, String, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import (
    Base,
    OwnedMixin,
    ProvenanceMixin,
    SoftDeleteMixin,
    TimestampMixin,
    enum_check,
    uuid_pk,
)
from app.models.enums import DraftKind, DraftStatus, PayPeriod, values


class SalaryOffer(OwnedMixin, TimestampMixin, SoftDeleteMixin, Base):
    """An offer the user actually received (confirmed) or was told about."""

    __tablename__ = "salary_offers"
    __table_args__ = (enum_check("pay_period", values(PayPeriod)),)

    id: Mapped[uuid.UUID] = uuid_pk()
    company_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("companies.id", ondelete="SET NULL"), index=True
    )
    application_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("job_applications.id", ondelete="SET NULL")
    )
    employer_name: Mapped[str] = mapped_column(String(255), nullable=False)
    position: Mapped[str] = mapped_column(String(200), nullable=False)
    gross_amount: Mapped[Decimal | None] = mapped_column(Numeric(12, 2))
    net_amount: Mapped[Decimal | None] = mapped_column(Numeric(12, 2))
    currency: Mapped[str] = mapped_column(String(3), nullable=False)
    pay_period: Mapped[str] = mapped_column(String(20), nullable=False)
    bonuses: Mapped[str | None] = mapped_column(Text)
    rotation: Mapped[str | None] = mapped_column(String(100))
    contract_duration: Mapped[str | None] = mapped_column(String(100))
    travel_expenses: Mapped[str | None] = mapped_column(Text)
    insurance: Mapped[str | None] = mapped_column(Text)
    accommodation: Mapped[str | None] = mapped_column(Text)
    overtime: Mapped[str | None] = mapped_column(Text)
    is_confirmed_offer: Mapped[bool] = mapped_column(Boolean, nullable=False,
                                                     server_default="false")
    source: Mapped[str | None] = mapped_column(Text)
    verified_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class SalaryBenchmark(OwnedMixin, ProvenanceMixin, TimestampMixin, Base):
    """Reported market salary data. Comparisons use the normalised monthly amount."""

    __tablename__ = "salary_benchmarks"
    __table_args__ = (
        enum_check("pay_period", values(PayPeriod)),
        *ProvenanceMixin.provenance_checks(),
    )

    id: Mapped[uuid.UUID] = uuid_pk()
    employer_name: Mapped[str | None] = mapped_column(String(255))
    position: Mapped[str] = mapped_column(String(200), nullable=False, index=True)
    country_code: Mapped[str | None] = mapped_column(String(2))
    amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    currency: Mapped[str] = mapped_column(String(3), nullable=False)
    pay_period: Mapped[str] = mapped_column(String(20), nullable=False)
    is_gross: Mapped[bool | None] = mapped_column(Boolean)
    monthly_normalized_amount: Mapped[Decimal | None] = mapped_column(Numeric(12, 2))
    normalization_note: Mapped[str | None] = mapped_column(Text)
    reported_on: Mapped[date | None] = mapped_column(Date)


class AIConversation(OwnedMixin, TimestampMixin, SoftDeleteMixin, Base):
    __tablename__ = "ai_conversations"

    id: Mapped[uuid.UUID] = uuid_pk()
    title: Mapped[str | None] = mapped_column(String(300))
    feature: Mapped[str] = mapped_column(String(50), nullable=False)  # assistant, interview, ...
    model: Mapped[str] = mapped_column(String(100), nullable=False)
    messages: Mapped[list] = mapped_column(JSONB, nullable=False, server_default="[]")
    input_tokens: Mapped[int] = mapped_column(Integer, nullable=False, server_default="0")
    output_tokens: Mapped[int] = mapped_column(Integer, nullable=False, server_default="0")


class AIGeneratedDraft(OwnedMixin, TimestampMixin, Base):
    """AI output. It can only leave the system after the user approves it explicitly."""

    __tablename__ = "ai_generated_drafts"
    __table_args__ = (
        enum_check("kind", values(DraftKind)),
        enum_check("status", values(DraftStatus)),
    )

    id: Mapped[uuid.UUID] = uuid_pk()
    conversation_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("ai_conversations.id", ondelete="SET NULL")
    )
    company_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("companies.id", ondelete="SET NULL")
    )
    application_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("job_applications.id", ondelete="SET NULL")
    )
    kind: Mapped[str] = mapped_column(String(20), nullable=False)
    language: Mapped[str] = mapped_column(String(5), nullable=False, server_default="en")
    subject: Mapped[str | None] = mapped_column(Text)
    body: Mapped[str] = mapped_column(Text, nullable=False)
    model: Mapped[str] = mapped_column(String(100), nullable=False)
    status: Mapped[str] = mapped_column(String(20), nullable=False, server_default="draft")
    approved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class SearchHistory(OwnedMixin, TimestampMixin, Base):
    __tablename__ = "search_history"

    id: Mapped[uuid.UUID] = uuid_pk()
    kind: Mapped[str] = mapped_column(String(30), nullable=False)  # companies, vacancies, ...
    query: Mapped[str] = mapped_column(Text, nullable=False)
    filters: Mapped[dict] = mapped_column(JSONB, nullable=False, server_default="{}")
    is_saved: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="false")
    results_count: Mapped[int | None] = mapped_column(Integer)
