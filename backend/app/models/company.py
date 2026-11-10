import uuid
from datetime import date, datetime
from decimal import Decimal

from sqlalchemy import (
    Date,
    DateTime,
    ForeignKey,
    Index,
    Numeric,
    PrimaryKeyConstraint,
    String,
    Text,
    UniqueConstraint,
    func,
    text,
)
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
from app.models.enums import (
    ContactKind,
    ContactStatus,
    EmailStatus,
    HiringStatus,
    Industry,
    PayPeriod,
    VacancyStatus,
    values,
)


class Company(OwnedMixin, ProvenanceMixin, TimestampMixin, SoftDeleteMixin, Base):
    """A maritime employer in the user's research workspace.

    Companies are kept regardless of whether they have open vacancies.
    """

    __tablename__ = "companies"
    __table_args__ = (
        enum_check("hiring_status", values(HiringStatus)),
        *ProvenanceMixin.provenance_checks(),
        Index(
            "uq_companies_user_name_country",
            "user_id",
            "normalized_name",
            "country_code",
            unique=True,
            postgresql_where=text("deleted_at IS NULL AND merged_into_id IS NULL"),
        ),
    )

    id: Mapped[uuid.UUID] = uuid_pk()
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    normalized_name: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    country_code: Mapped[str | None] = mapped_column(String(2), index=True)  # ISO 3166-1 alpha-2
    headquarters: Mapped[str | None] = mapped_column(String(255))
    hiring_status: Mapped[str] = mapped_column(String(30), nullable=False, server_default="unknown")
    speculative_policy: Mapped[str | None] = mapped_column(Text)
    careers_url: Mapped[str | None] = mapped_column(Text)
    recruitment_email: Mapped[str | None] = mapped_column(String(320))
    fleet_summary: Mapped[str | None] = mapped_column(Text)
    description: Mapped[str | None] = mapped_column(Text)
    latitude: Mapped[Decimal | None] = mapped_column(Numeric(9, 6))
    longitude: Mapped[Decimal | None] = mapped_column(Numeric(9, 6))
    # Duplicate handling: merged records point at the surviving company.
    merged_into_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("companies.id", ondelete="SET NULL")
    )


class CompanyWebsite(OwnedMixin, TimestampMixin, Base):
    __tablename__ = "company_websites"
    __table_args__ = (
        UniqueConstraint("company_id", "url"),
        enum_check("kind", ("main", "careers", "fleet", "contact", "other")),
    )

    id: Mapped[uuid.UUID] = uuid_pk()
    company_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("companies.id", ondelete="CASCADE"), nullable=False,
        index=True,
    )
    url: Mapped[str] = mapped_column(Text, nullable=False)
    kind: Mapped[str] = mapped_column(String(20), nullable=False, server_default="main")


class CompanySource(OwnedMixin, TimestampMixin, Base):
    """Evidence trail: every page / registry / directory a company fact came from."""

    __tablename__ = "company_sources"
    __table_args__ = (
        enum_check(
            "source_type",
            ("official_website", "careers_page", "business_directory", "fleet_registry",
             "recruitment_page", "search_api", "publication", "professional_profile",
             "user_entry", "other"),
        ),
    )

    id: Mapped[uuid.UUID] = uuid_pk()
    company_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("companies.id", ondelete="CASCADE"), nullable=False,
        index=True,
    )
    url: Mapped[str | None] = mapped_column(Text)
    title: Mapped[str | None] = mapped_column(String(500))
    source_type: Mapped[str] = mapped_column(String(30), nullable=False)
    retrieved_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    excerpt: Mapped[str | None] = mapped_column(Text)
    fields_supported: Mapped[list] = mapped_column(JSONB, nullable=False, server_default="[]")


class CompanyIndustry(OwnedMixin, Base):
    __tablename__ = "company_industries"
    __table_args__ = (
        PrimaryKeyConstraint("company_id", "industry"),
        enum_check("industry", values(Industry)),
    )

    company_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("companies.id", ondelete="CASCADE"), nullable=False
    )
    industry: Mapped[str] = mapped_column(String(30), nullable=False)


class CompanyContact(OwnedMixin, ProvenanceMixin, TimestampMixin, SoftDeleteMixin, Base):
    """A publicly listed recruitment contact. Inferred e-mails are flagged, never 'verified'."""

    __tablename__ = "company_contacts"
    __table_args__ = (
        enum_check("contact_kind", values(ContactKind)),
        enum_check("email_status", values(EmailStatus)),
        enum_check("contact_status", values(ContactStatus)),
        *ProvenanceMixin.provenance_checks(),
        Index("ix_company_contacts_user_email", "user_id", "email"),
    )

    id: Mapped[uuid.UUID] = uuid_pk()
    company_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("companies.id", ondelete="CASCADE"), nullable=False,
        index=True,
    )
    contact_kind: Mapped[str] = mapped_column(String(20), nullable=False, server_default="person")
    full_name: Mapped[str | None] = mapped_column(String(200))
    job_title: Mapped[str | None] = mapped_column(String(200))
    email: Mapped[str | None] = mapped_column(String(320))
    email_status: Mapped[str | None] = mapped_column(String(20))
    phone: Mapped[str | None] = mapped_column(String(50))
    linkedin_url: Mapped[str | None] = mapped_column(Text)
    contact_status: Mapped[str] = mapped_column(String(20), nullable=False, server_default="new")


class ContactSource(OwnedMixin, TimestampMixin, Base):
    __tablename__ = "contact_sources"

    id: Mapped[uuid.UUID] = uuid_pk()
    contact_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("company_contacts.id", ondelete="CASCADE"), nullable=False,
        index=True,
    )
    url: Mapped[str] = mapped_column(Text, nullable=False)
    retrieved_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    excerpt: Mapped[str | None] = mapped_column(Text)


class CompanyNote(OwnedMixin, TimestampMixin, SoftDeleteMixin, Base):
    __tablename__ = "company_notes"

    id: Mapped[uuid.UUID] = uuid_pk()
    company_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("companies.id", ondelete="CASCADE"), nullable=False,
        index=True,
    )
    body: Mapped[str] = mapped_column(Text, nullable=False)


class Vacancy(OwnedMixin, TimestampMixin, SoftDeleteMixin, Base):
    """A job posting. Search snippets stay `unverified` until the source page is checked."""

    __tablename__ = "vacancies"
    __table_args__ = (
        enum_check("status", values(VacancyStatus)),
        enum_check("salary_period", values(PayPeriod)),
        Index("ix_vacancies_user_status", "user_id", "status"),
        UniqueConstraint("user_id", "source_url"),
    )

    id: Mapped[uuid.UUID] = uuid_pk()
    company_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("companies.id", ondelete="SET NULL"), index=True
    )
    employer_name: Mapped[str] = mapped_column(String(255), nullable=False)
    position: Mapped[str] = mapped_column(String(200), nullable=False)
    country_code: Mapped[str | None] = mapped_column(String(2))
    vessel_type: Mapped[str | None] = mapped_column(String(100))
    salary_min: Mapped[Decimal | None] = mapped_column(Numeric(12, 2))
    salary_max: Mapped[Decimal | None] = mapped_column(Numeric(12, 2))
    currency: Mapped[str | None] = mapped_column(String(3))
    salary_period: Mapped[str | None] = mapped_column(String(20))
    contract_duration: Mapped[str | None] = mapped_column(String(100))
    rotation: Mapped[str | None] = mapped_column(String(100))
    requirements: Mapped[str | None] = mapped_column(Text)
    application_deadline: Mapped[date | None] = mapped_column(Date)
    status: Mapped[str] = mapped_column(String(20), nullable=False, server_default="unverified")
    source_url: Mapped[str] = mapped_column(Text, nullable=False)
    discovered_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    last_verified_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
