"""Contacts: an inferred e-mail can never be marked verified; search history lookup index.

Revision ID: 0002_contact_rules
Revises: 0001_initial
"""
from collections.abc import Sequence

from alembic import op

revision: str = "0002_contact_rules"
down_revision: str | None = "0001_initial"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_check_constraint(
        "inferred_not_verified",
        "company_contacts",
        "NOT (email_status = 'inferred' AND verification_status = 'verified')",
    )
    op.create_index("ix_search_history_user_created", "search_history",
                    ["user_id", "created_at"])


def downgrade() -> None:
    op.drop_index("ix_search_history_user_created", table_name="search_history")
    op.drop_constraint("inferred_not_verified", "company_contacts",
                       type_="check")
