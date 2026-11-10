import uuid
from datetime import UTC, datetime, timedelta

import pytest
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError

from app.db.session import get_engine
from tests.conftest import auth_headers


def test_dashboard_is_empty_for_new_user(client):
    body = client.get("/api/v1/dashboard/summary", headers=auth_headers("fresh")).json()
    assert set(body["counts"].values()) == {0}
    assert body["new_companies"] == [] and body["upcoming_follow_ups"] == []


def _user_id(client, sub: str) -> str:
    return client.get("/api/v1/me", headers=auth_headers(sub)).json()["id"]


def test_dashboard_counts_real_rows_only_for_owner(client):
    owner, other = _user_id(client, "owner"), _user_id(client, "other")
    now = datetime.now(UTC)
    with get_engine().begin() as conn:
        for uid in (owner, other):
            cid = uuid.uuid4()
            conn.execute(text(
                "INSERT INTO companies (id, user_id, name, normalized_name) "
                "VALUES (:id, :u, 'Test Fishing AS', 'test fishing as')"), {"id": cid, "u": uid})
            conn.execute(text(
                "INSERT INTO job_applications (user_id, company_id, status, last_reply_at) "
                "VALUES (:u, :c, 'interview', :t)"), {"u": uid, "c": cid, "t": now})
            conn.execute(text(
                "INSERT INTO follow_up_tasks (user_id, company_id, title, due_at) "
                "VALUES (:u, :c, 'Follow up', :t)"), {"u": uid, "c": cid,
                                                       "t": now + timedelta(days=3)})
    counts = client.get("/api/v1/dashboard/summary",
                        headers=auth_headers("owner")).json()["counts"]
    assert counts == {"companies": 1, "verified_contacts": 0, "applications_sent": 1,
                      "replies_received": 1, "pending_follow_ups": 1, "interviews": 1,
                      "offers": 0}


def test_verified_requires_source_constraint(client):
    uid = _user_id(client, "checker")
    with pytest.raises(DBAPIError), get_engine().begin() as conn:
        conn.execute(text(
            "INSERT INTO companies (user_id, name, normalized_name, verification_status) "
            "VALUES (:u, 'X', 'x', 'verified')"), {"u": uid})


@pytest.fixture
def rls_role():
    """An ordinary (non-superuser) role, like the one production must use."""
    with get_engine().begin() as conn:
        conn.execute(text("DROP ROLE IF EXISTS seaspace_rls_probe"))
        conn.execute(text("CREATE ROLE seaspace_rls_probe NOLOGIN"))
        conn.execute(text(
            "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public "
            "TO seaspace_rls_probe"))
    yield "seaspace_rls_probe"
    with get_engine().begin() as conn:
        conn.execute(text("DROP OWNED BY seaspace_rls_probe"))
        conn.execute(text("DROP ROLE seaspace_rls_probe"))


def test_row_level_security_isolates_users(client, rls_role):
    alice, bob = _user_id(client, "rls-alice"), _user_id(client, "rls-bob")
    with get_engine().begin() as conn:
        for uid in (alice, bob):
            conn.execute(text("INSERT INTO candidate_profiles (user_id, label) VALUES (:u, 'p')"),
                         {"u": uid})

    with get_engine().connect() as conn:
        conn.execute(text(f"SET ROLE {rls_role}"))
        # No context → nothing visible.
        assert conn.scalar(text("SELECT count(*) FROM candidate_profiles")) == 0

        conn.execute(text("SELECT set_config('app.user_id', :u, true)"), {"u": alice})
        rows = conn.execute(text("SELECT user_id::text FROM candidate_profiles")).all()
        assert [r[0] for r in rows] == [alice]

        # Writing a row for someone else is refused by WITH CHECK.
        with pytest.raises(DBAPIError):
            conn.execute(text(
                "INSERT INTO candidate_profiles (user_id, label) VALUES (:u, 'hijack')"),
                {"u": bob})
        conn.rollback()


def test_api_works_end_to_end_under_rls_with_ordinary_role(client):
    """Run the real API through a non-superuser login role, as production must."""
    from fastapi.testclient import TestClient
    from sqlalchemy import create_engine
    from sqlalchemy.engine import make_url
    from sqlalchemy.orm import sessionmaker

    from app.db.session import get_db
    from app.main import create_app

    with get_engine().begin() as conn:
        conn.execute(text("DROP ROLE IF EXISTS seaspace_rls_app"))
        conn.execute(text("CREATE ROLE seaspace_rls_app LOGIN PASSWORD 'rls-test'"))
        conn.execute(text("GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public "
                          "TO seaspace_rls_app"))
    url = make_url(str(get_engine().url)).set(username="seaspace_rls_app", password="rls-test")
    engine = create_engine(url)
    maker = sessionmaker(bind=engine, expire_on_commit=False)

    def db_override():
        s = maker()
        try:
            yield s
        finally:
            s.close()

    app = create_app()
    app.dependency_overrides[get_db] = db_override
    try:
        rls_client = TestClient(app)
        alice, bob = auth_headers("e2e-alice"), auth_headers("e2e-bob")
        created = rls_client.post("/api/v1/profiles", json={"label": "A"}, headers=alice)
        assert created.status_code == 201, created.text
        pid = created.json()["id"]
        assert rls_client.patch(f"/api/v1/profiles/{pid}", json={"summary": "s"},
                                headers=alice).status_code == 200
        assert rls_client.get(f"/api/v1/profiles/{pid}", headers=bob).status_code == 404
        assert rls_client.get("/api/v1/dashboard/summary", headers=alice).status_code == 200

        # Phase 3 endpoints under RLS: companies, contacts, fleet, merge, vacancies.
        api = "/api/v1"
        a = rls_client.post(f"{api}/companies", json={"name": "RLS Fish", "industries": ["krill"]},
                            headers=alice)
        assert a.status_code == 201, a.text
        b = rls_client.post(f"{api}/companies", json={"name": "RLS Fish Two", "allow_duplicate": True},
                            headers=alice).json()
        assert rls_client.post(f"{api}/companies/{b['id']}/contacts", json={"email": "crew@rls.example"},
                               headers=alice).status_code == 201
        vessel = rls_client.post(f"{api}/vessels", json={"name": "RLS Vessel"}, headers=alice).json()
        assert rls_client.post(f"{api}/vessels/{vessel['id']}/links", headers=alice,
                               json={"company_id": b["id"], "role": "operator"}).status_code == 201
        merged = rls_client.post(f"{api}/companies/{b['id']}/merge", json={"into_id": a.json()["id"]},
                                 headers=alice)
        assert merged.status_code == 200, merged.text
        assert merged.json()["contacts_count"] == 1 and merged.json()["vessels"]
        assert rls_client.post(f"{api}/vacancies", headers=alice, json={
            "employer_name": "RLS Fish", "position": "AB", "source_url": "https://rls.example/j"}
        ).status_code == 201
        assert rls_client.get(f"{api}/companies", headers=bob).json() == []
        assert rls_client.get(f"{api}/contacts", headers=bob).json() == []
        assert rls_client.get(f"{api}/vessels", headers=bob).json() == []
        assert len(rls_client.get(f"{api}/vessel-types", headers=bob).json()) == 9
    finally:
        engine.dispose()
        with get_engine().begin() as conn:
            conn.execute(text("DROP OWNED BY seaspace_rls_app"))
            conn.execute(text("DROP ROLE seaspace_rls_app"))
