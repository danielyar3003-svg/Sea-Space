"""Fleet intelligence: Company → Vessel → Owner/Operator → Vessel type.

Owner, operator and employer are modelled separately on purpose — they are often
different legal entities.
"""

import uuid
from datetime import date

from sqlalchemy import Date, ForeignKey, Index, String, Text, UniqueConstraint, text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import (
    Base,
    OwnedMixin,
    ProvenanceMixin,
    SoftDeleteMixin,
    TimestampMixin,
    uuid_pk,
)


class VesselType(TimestampMixin, Base):
    """Shared reference data (not user-owned)."""

    __tablename__ = "vessel_types"

    id: Mapped[uuid.UUID] = uuid_pk()
    code: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    category: Mapped[str] = mapped_column(String(50), nullable=False)  # fishing, merchant, ...
    typical_positions: Mapped[list] = mapped_column(JSONB, nullable=False, server_default="[]")


class Vessel(OwnedMixin, ProvenanceMixin, TimestampMixin, SoftDeleteMixin, Base):
    __tablename__ = "vessels"
    __table_args__ = (
        *ProvenanceMixin.provenance_checks(),
        Index(
            "uq_vessels_user_imo",
            "user_id",
            "imo_number",
            unique=True,
            postgresql_where=text("imo_number IS NOT NULL AND deleted_at IS NULL"),
        ),
    )

    id: Mapped[uuid.UUID] = uuid_pk()
    name: Mapped[str] = mapped_column(String(200), nullable=False, index=True)
    imo_number: Mapped[str | None] = mapped_column(String(7))
    flag_country_code: Mapped[str | None] = mapped_column(String(2))
    vessel_type_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("vessel_types.id", ondelete="SET NULL")
    )
    fishing_specialization: Mapped[str | None] = mapped_column(String(200))
    home_country_code: Mapped[str | None] = mapped_column(String(2))
    notes: Mapped[str | None] = mapped_column(Text)


class _VesselCompanyLink(OwnedMixin, ProvenanceMixin, TimestampMixin):
    id: Mapped[uuid.UUID] = uuid_pk()
    valid_from: Mapped[date | None] = mapped_column(Date)
    valid_to: Mapped[date | None] = mapped_column(Date)


class VesselOwner(_VesselCompanyLink, Base):
    __tablename__ = "vessel_owners"
    __table_args__ = (
        UniqueConstraint("vessel_id", "company_id", "valid_from"),
        *ProvenanceMixin.provenance_checks(),
    )

    vessel_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("vessels.id", ondelete="CASCADE"), nullable=False,
        index=True,
    )
    company_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("companies.id", ondelete="CASCADE"), nullable=False,
        index=True,
    )


class VesselOperator(_VesselCompanyLink, Base):
    __tablename__ = "vessel_operators"
    __table_args__ = (
        UniqueConstraint("vessel_id", "company_id", "valid_from"),
        *ProvenanceMixin.provenance_checks(),
    )

    vessel_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("vessels.id", ondelete="CASCADE"), nullable=False,
        index=True,
    )
    company_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("companies.id", ondelete="CASCADE"), nullable=False,
        index=True,
    )
    is_crewing_employer: Mapped[bool | None] = mapped_column()  # None = unknown
