from datetime import UTC, datetime, timedelta

from tests.conftest import auth_headers

API = "/api/v1"


def _company(client, h, name="CRM Fishing AS"):
    return client.post(f"{API}/companies", json={"name": name}, headers=h).json()["id"]


def test_application_pipeline_history_and_follow_ups(client):
    h = auth_headers("crm1")
    cid = _company(client, h)
    contact = client.post(f"{API}/companies/{cid}/contacts", headers=h,
                          json={"full_name": "Kari", "email": "kari@crm.example"}).json()
    r = client.post(f"{API}/applications", headers=h, json={
        "company_id": cid, "position": "Trawl Deckhand", "contact_id": contact["id"]})
    assert r.status_code == 201, r.text
    app = r.json()
    assert app["status"] == "discovered" and app["contact_name"] == "Kari"
    assert [x["to_status"] for x in app["history"]] == ["discovered"]

    # Moving to "sent" records history, stamps sent_at, and can schedule a follow-up.
    r = client.patch(f"{API}/applications/{app['id']}", headers=h, json={
        "status": "sent", "status_note": "Sent CV by e-mail", "follow_up_in_days": 7,
        "follow_up_title": "Напомнить о себе"})
    app = r.json()
    assert app["sent_at"] is not None
    assert app["history"][0]["from_status"] == "discovered"
    assert app["history"][0]["note"] == "Sent CV by e-mail"
    assert len(app["follow_ups"]) == 1 and app["next_follow_up_at"] is not None
    assert app["follow_ups"][0]["title"] == "Напомнить о себе"

    fid = app["follow_ups"][0]["id"]
    done = client.patch(f"{API}/follow-ups/{fid}", headers=h, json={"completed": True}).json()
    assert done["completed_at"] is not None
    assert client.get(f"{API}/applications/{app['id']}", headers=h).json()["next_follow_up_at"] is None

    app = client.patch(f"{API}/applications/{app['id']}", headers=h, json={"status": "interview"}).json()
    assert app["last_reply_at"] is not None  # an interview means the employer replied

    board = client.get(f"{API}/applications/board", headers=h).json()
    assert len(board) == 14  # every pipeline status is a column
    assert [c["status"] for c in board][:3] == ["discovered", "researched", "ready_to_contact"]
    assert next(c for c in board if c["status"] == "interview")["applications"][0]["id"] == app["id"]


def test_contact_must_belong_to_company(client):
    h = auth_headers("crm2")
    a, b = _company(client, h, "Alpha AS"), _company(client, h, "Beta AS")
    contact = client.post(f"{API}/companies/{b}/contacts", headers=h, json={"email": "x@beta.example"}).json()
    r = client.post(f"{API}/applications", headers=h, json={"company_id": a, "contact_id": contact["id"]})
    assert r.status_code == 422


def test_stats_and_overdue_follow_ups(client):
    h = auth_headers("crm3")
    cid = _company(client, h)
    a1 = client.post(f"{API}/applications", headers=h, json={"company_id": cid, "status": "sent"}).json()
    client.post(f"{API}/applications", headers=h, json={"company_id": cid, "status": "sent"})
    client.post(f"{API}/applications", headers=h, json={"company_id": cid})
    client.patch(f"{API}/applications/{a1['id']}", headers=h, json={"status": "replied"})
    past = (datetime.now(UTC) - timedelta(days=2)).isoformat()
    client.post(f"{API}/follow-ups", headers=h, json={"title": "Call crewing", "due_at": past,
                                                      "company_id": cid})
    s = client.get(f"{API}/applications/stats", headers=h).json()
    assert s["total"] == 3 and s["sent"] == 2 and s["replied"] == 1
    assert s["reply_rate"] == 0.5
    assert s["overdue_follow_ups"] == 1 and s["open_follow_ups"] == 1
    overdue = client.get(f"{API}/follow-ups?state=overdue", headers=h).json()
    assert overdue[0]["overdue"] is True and overdue[0]["company_name"] == "CRM Fishing AS"
    dash = client.get(f"{API}/dashboard/summary", headers=h).json()["counts"]
    assert dash["applications_sent"] == 2 and dash["replies_received"] == 1
    assert dash["pending_follow_ups"] == 1


def test_stats_without_sent_applications_have_no_rate(client):
    s = client.get(f"{API}/applications/stats", headers=auth_headers("crm4")).json()
    assert s["reply_rate"] is None and s["median_days_to_reply"] is None
    assert s["by_status"]["discovered"] == 0


def test_company_timeline(client):
    h = auth_headers("crm5")
    cid = _company(client, h)
    client.post(f"{API}/companies/{cid}/notes", headers=h, json={"body": "Called the office"})
    app = client.post(f"{API}/applications", headers=h, json={"company_id": cid, "position": "AB"}).json()
    client.patch(f"{API}/applications/{app['id']}", headers=h, json={"status": "sent"})
    kinds = [e["kind"] for e in client.get(f"{API}/companies/{cid}/timeline", headers=h).json()]
    assert kinds[-1] == "company_added"
    assert {"note", "application_created", "status_changed"} <= set(kinds)


def test_crm_isolation_and_delete(client):
    owner, other = auth_headers("crm-owner"), auth_headers("crm-other")
    cid = _company(client, owner)
    app = client.post(f"{API}/applications", headers=owner, json={"company_id": cid}).json()
    assert client.get(f"{API}/applications/{app['id']}", headers=other).status_code == 404
    assert client.patch(f"{API}/applications/{app['id']}", headers=other,
                        json={"status": "sent"}).status_code == 404
    assert client.get(f"{API}/applications", headers=other).json() == []
    assert client.post(f"{API}/applications", headers=other, json={"company_id": cid}).status_code == 404
    assert client.delete(f"{API}/applications/{app['id']}", headers=owner).status_code == 204
    assert client.get(f"{API}/applications", headers=owner).json() == []
