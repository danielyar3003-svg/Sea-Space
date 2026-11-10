import uuid
from datetime import date
from decimal import Decimal

from sqlalchemy import (
    BigInteger,
    Boolean,
    Date,
    ForeignKey,
    Index,
    Numeric,
    String,
    Text,
    text,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, OwnedMixin, SoftDeleteMixin, TimestampMixin, enum_check, uuid_pk
from app.models.enums import DocumentCategory, EnglishLevel, values


class CandidateProfile(OwnedMixin, TimestampMixin, SoftDeleteMixin, Base):
    """A position-specific professional profile. A user may have several; one is primary.

    Only facts the user entered are stored — nothing is generated or assumed.
    """

    __tablename__ = "candidate_profiles"
    __table_args__ = (
        enum_check("english_level", values(EnglishLevel)),
        Index(
            "uq_candidate_profiles_primary",
            "user_id",
            unique=True,
            postgresql_where=text("is_primary AND deleted_at IS NULL"),
        ),
    )

    id: Mapped[uuid.UUID] = uuid_pk()
    label: Mapped[str] = mapped_column(String(120), nullable=False, server_default="Main profile")
    is_primary: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="false")
    full_name: Mapped[str | None] = mapped_column(String(200))
    nationality: Mapped[str | None] = mapped_column(String(100))
    english_level: Mapped[str | None] = mapped_column(String(30))
    years_of_experience: Mapped[Decimal | None] = mapped_column(Numeric(4, 1))
    experience_is_approximate: Mapped[bool] = mapped_column(
        Boolean, nullable=False, server_default="true"
    )
    target_positions: Mapped[list] = mapped_column(JSONB, nullable=False, server_default="[]")
    experience_areas: Mapped[list] = mapped_column(JSONB, nullable=False, server_default="[]")
    languages: Mapped[list] = mapped_column(JSONB, nullable=False, server_default="[]")
    summary: Mapped[str | None] = mapped_column(Text)
    phone: Mapped[str | None] = mapped_column(String(50))
    contact_email: Mapped[str | None] = mapped_column(String(320))
    home_port: Mapped[str | None] = mapped_column(String(200))

    experience: Mapped[list["CandidateExperience"]] = relationship(
        back_populates="profile",
        cascade="all, delete-orphan",
        order_by="CandidateExperience.sort_order",
    )


class CandidateExperience(OwnedMixin, TimestampMixin, Base):
    __tablename__ = "candidate_experience"

    id: Mapped[uuid.UUID] = uuid_pk()
    profile_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("candidate_profiles.id", ondelete="CASCADE"), nullable=False,
        index=True,
    )
    vessel_name: Mapped[str | None] = mapped_column(String(200))
    vessel_type: Mapped[str | None] = mapped_column(String(100))
    employer_name: Mapped[str | None] = mapped_column(String(200))
    position: Mapped[str | None] = mapped_column(String(120))
    duties: Mapped[list] = mapped_column(JSONB, nullable=False, server_default="[]")
    # Dates are optional: they are never invented when the user has not provided them.
    start_date: Mapped[date | None] = mapped_column(Date)
    end_date: Mapped[date | None] = mapped_column(Date)
    notes: Mapped[str | None] = mapped_column(Text)
    sort_order: Mapped[int] = mapped_column(nullable=False, server_default="0")

    profile: Mapped[CandidateProfile] = relationship(back_populates="experience")


class CandidateDocument(OwnedMixin, TimestampMixin, SoftDeleteMixin, Base):
    """File metadata. The file itself lives in private Supabase Storage (`storage_path`)."""

    __tablename__ = "candidate_documents"
    __table_args__ = (enum_check("category", values(DocumentCategory)),)

    id: Mapped[uuid.UUID] = uuid_pk()
    profile_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("candidate_profiles.id", ondelete="SET NULL")
    )
    category: Mapped[str] = mapped_column(String(30), nullable=False)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    version_label: Mapped[str | None] = mapped_column(String(100))  # e.g. "CV — Trawl Deckhand"
    storage_path: Mapped[str] = mapped_column(Text, nullable=False)
    mime_type: Mapped[str] = mapped_column(String(100), nullable=False)
    size_bytes: Mapped[int] = mapped_column(BigInteger, nullable=False)
    sha256: Mapped[str] = mapped_column(String(64), nullable=False)
    is_encrypted: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default="true")
    issued_on: Mapped[date | None] = mapped_column(Date)
    expires_on: Mapped[date | None] = mapped_column(Date, index=True)


class CandidateCertificate(OwnedMixin, TimestampMixin, SoftDeleteMixin, Base):
    __tablename__ = "candidate_certificates"

    id: Mapped[uuid.UUID] = uuid_pk()
    profile_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("candidate_profiles.id", ondelete="SET NULL")
    )
    document_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("candidate_documents.id", ondelete="SET NULL")
    )
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    issuing_authority: Mapped[str | None] = mapped_column(String(200))
    certificate_number: Mapped[str | None] = mapped_column(String(100))
    issued_on: Mapped[date | None] = mapped_column(Date)
    expires_on: Mapped[date | None] = mapped_column(Date, index=True)
