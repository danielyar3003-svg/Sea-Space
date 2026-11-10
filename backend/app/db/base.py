"""Declarative base, naming conventions and shared column mixins."""

import uuid
from datetime import datetime
from decimal import Decimal

from sqlalchemy import (
    CheckConstraint,
    DateTime,
    ForeignKey,
    MetaData,
    Numeric,
    String,
    Text,
    func,
    text,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import DeclarativeBase, Mapped, declared_attr, mapped_column

NAMING_CONVENTION = {
    "ix": "ix_%(column_0_label)s",
    "uq": "uq_%(table_name)s_%(column_0_N_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s",
}


class Base(DeclarativeBase):
    metadata = MetaData(naming_convention=NAMING_CONVENTION)


def uuid_pk() -> Mapped[uuid.UUID]:
    return mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        server_default=text("gen_random_uuid()"),
    )


class TimestampMixin:
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )


class SoftDeleteMixin:
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class OwnedMixin:
    """Row belongs to exactly one user. Covered by row-level security (see migrations)."""

    @declared_attr
    def user_id(cls) -> Mapped[uuid.UUID]:  # noqa: N805
        return mapped_column(
            UUID(as_uuid=True),
            ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
            index=True,
        )


VERIFICATION_STATUSES = ("verified", "unverified", "inferred", "user_provided")


class ProvenanceMixin:
    """Source attribution. Nothing is 'verified' without a source and a verification date."""

    source_url: Mapped[str | None] = mapped_column(Text)
    verification_status: Mapped[str] = mapped_column(
        String(20), nullable=False, server_default="unverified"
    )
    last_verified_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    confidence: Mapped[Decimal | None] = mapped_column(Numeric(3, 2))

    @staticmethod
    def provenance_checks() -> tuple[CheckConstraint, ...]:
        statuses = ", ".join(f"'{s}'" for s in VERIFICATION_STATUSES)
        return (
            CheckConstraint(f"verification_status IN ({statuses})", name="verification_status"),
            CheckConstraint("confidence IS NULL OR (confidence >= 0 AND confidence <= 1)",
                            name="confidence_range"),
            # A record may only be marked verified when it has a source and a date.
            CheckConstraint(
                "verification_status <> 'verified' "
                "OR (source_url IS NOT NULL AND last_verified_at IS NOT NULL)",
                name="verified_requires_source",
            ),
        )


def enum_check(column: str, values: tuple[str, ...], name: str | None = None) -> CheckConstraint:
    allowed = ", ".join(f"'{v}'" for v in values)
    return CheckConstraint(f"{column} IN ({allowed})", name=name or column)
