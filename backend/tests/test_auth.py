import time

from tests.conftest import auth_headers, make_token


def test_health(client):
    assert client.get("/health").json() == {"status": "ok"}


def test_ready_reports_integrations_without_secrets(client):
    body = client.get("/health/ready").json()
    assert body["status"] == "ready"
    assert body["integrations"]["supabase_auth"] is True
    assert body["integrations"]["anthropic"] is False
    assert "secret" not in str(body).lower()


def test_missing_token_is_rejected(client):
    r = client.get("/api/v1/me")
    assert r.status_code == 401


def test_bad_signature_is_rejected(client):
    import jwt

    forged = jwt.encode({"sub": "x", "aud": "authenticated", "exp": int(time.time()) + 60},
                        "wrong-secret-wrong-secret-wrong-secret!!", algorithm="HS256")
    r = client.get("/api/v1/me", headers={"Authorization": f"Bearer {forged}"})
    assert r.status_code == 401


def test_expired_token_is_rejected(client):
    token = make_token(exp=int(time.time()) - 10)
    r = client.get("/api/v1/me", headers={"Authorization": f"Bearer {token}"})
    assert r.status_code == 401
    assert r.json()["detail"] == "Token expired"


def test_wrong_audience_and_issuer_are_rejected(client):
    for override in ({"aud": "anon"}, {"iss": "https://evil.example/auth/v1"}):
        token = make_token(**override)
        r = client.get("/api/v1/me", headers={"Authorization": f"Bearer {token}"})
        assert r.status_code == 401, override


def test_first_request_provisions_user(client):
    headers = auth_headers("subject-1", email="a@example.com")
    first = client.get("/api/v1/me", headers=headers).json()
    second = client.get("/api/v1/me", headers=headers).json()
    assert first["id"] == second["id"]
    assert first["email"] == "a@example.com"


def test_security_headers(client):
    r = client.get("/health")
    assert r.headers["x-content-type-options"] == "nosniff"
    assert r.headers["x-frame-options"] == "DENY"
