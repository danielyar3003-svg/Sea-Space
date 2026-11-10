"""Engine/session factory with per-transaction row-level-security context.

Every request session carries the authenticated user's id in `session.info["user_id"]`.
At the start of each transaction it is published to PostgreSQL as the transaction-local
setting `app.user_id`, which the RLS policies (see the initial migration) compare against.
Because the setting is transaction-local it can never leak to another pooled connection.
"""

from collections.abc import Iterator
from functools import lru_cache

from sqlalchemy import Engine, create_engine, event, text
from sqlalchemy.orm import Session, sessionmaker

from app.core.config import get_settings


@lru_cache
def get_engine() -> Engine:
    settings = get_settings()
    return create_engine(
        settings.database_url,
        pool_pre_ping=True,
        pool_size=settings.db_pool_size,
    )


@lru_cache
def get_sessionmaker() -> sessionmaker[Session]:
    return sessionmaker(bind=get_engine(), expire_on_commit=False)


@event.listens_for(Session, "after_begin")
def _apply_rls_context(session: Session, transaction, connection) -> None:  # noqa: ANN001
    user_id = session.info.get("user_id")
    if user_id is not None:
        connection.execute(
            text("SELECT set_config('app.user_id', :uid, true)"), {"uid": str(user_id)}
        )


def get_db() -> Iterator[Session]:
    session = get_sessionmaker()()
    try:
        yield session
    finally:
        session.close()
