"""Test fixtures. Tests run against a real PostgreSQL database (TEST_DATABASE_URL)."""

import os
import time
import uuid

TEST_DB = os.environ.get(
    "TEST_DATABASE_URL", "postgresql+psycopg://seaspace:seaspace@localhost:5432/seaspace_test"
)
TEST_SUPABASE_URL = "https://test-project.supabase.co"
TEST_JWT_SECRET = "test-only-secret-not-used-anywhere-else-0123456789"

os.environ.update({
    "APP_ENV": "test",
    "DATABASE_URL": TEST_DB,
    "SUPABASE_URL": TEST_SUPABASE_URL,
    "SUPABASE_JWT_SECRET": TEST_JWT_SECRET,
    # Discovery tests read a local fixture website on 127.0.0.1.
    "DISCOVERY_ALLOW_PRIVATE_HOSTS": "true",
    "DISCOVERY_MIN_INTERVAL_SECONDS": "0",
})

import jwt  # noqa: E402
import pytest  # noqa: E402
from alembic import command  # noqa: E402
from alembic.config import Config  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402
from sqlalchemy import text  # noqa: E402

from app.db.session import get_engine  # noqa: E402
from app.main import create_app  # noqa: E402
from app.models import Base  # noqa: E402

BACKEND_DIR = os.path.dirname(os.path.dirname(__file__))


@pytest.fixture(scope="session", autouse=True)
def migrated_database():
    cfg = Config(os.path.join(BACKEND_DIR, "alembic.ini"))
    cfg.set_main_option("script_location", os.path.join(BACKEND_DIR, "alembic"))
    command.downgrade(cfg, "base")
    command.upgrade(cfg, "head")
    yield


@pytest.fixture(autouse=True)
def clean_tables():
    yield
    tables = [t.name for t in Base.metadata.sorted_tables if t.name != "vessel_types"]
    with get_engine().begin() as conn:
        conn.execute(text(f"TRUNCATE {', '.join(tables)} CASCADE"))


@pytest.fixture
def client() -> TestClient:
    return TestClient(create_app())


def make_token(sub: str | None = None, email: str = "sailor@example.com", **overrides) -> str:
    now = int(time.time())
    claims = {
        "sub": sub or str(uuid.uuid4()),
        "email": email,
        "aud": "authenticated",
        "role": "authenticated",
        "iss": f"{TEST_SUPABASE_URL}/auth/v1",
        "iat": now,
        "exp": now + 3600,
        **overrides,
    }
    return jwt.encode(claims, TEST_JWT_SECRET, algorithm="HS256")


def auth_headers(sub: str | None = None, **kw) -> dict[str, str]:
    return {"Authorization": f"Bearer {make_token(sub, **kw)}"}
