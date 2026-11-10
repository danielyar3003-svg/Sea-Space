from tests.conftest import auth_headers

API = "/api/v1"


def _create(client, h, **body):
    r = client.post(f"{API}/companies", json={"name": "Test Fishing AS", **body}, headers=h)
    return r


def test_create_and_read_company_with_provenance(client):
    h = auth_headers("co1")
    r = _create(client, h, country_code="no", industries=["trawling", "fishing"],
                websites=[{"url": "https://testfishing.example/", "kind": "main"}])
    assert r.status_code == 201, r.text
    c = r.json()
    assert c["country_code"] == "NO"
    assert c["industries"] == ["fishing", "trawling"]
    assert c["hiring_status"] == "unknown"
    assert c["verification_status"] == "user_provided"  # nothing claimed as verified
    assert c["websites"][0]["url"] == "https://testfishing.example/"

    listed = client.get(f"{API}/companies?country=NO&industry=trawling", headers=h).json()
    assert [x["id"] for x in listed] == [c["id"]]
    assert client.get(f"{API}/companies?q=fishing", headers=h).json()[0]["id"] == c["id"]


def test_duplicate_detection_and_override(client):
    h = auth_headers("co2")
    _create(client, h, name="Nergård AS", country_code="NO")

    same = client.post(f"{API}/companies", json={"name": "Nergard", "country_code": "NO",
                                                 "allow_duplicate": True}, headers=h)
    assert same.status_code == 409
    assert same.json()["detail"]["can_override"] is False  # exact same name + country

    other_country = client.post(f"{API}/companies", json={"name": "Nergård A/S", "country_code": "DK"},
                                headers=h)
    assert other_country.status_code == 409
    assert other_country.json()["detail"]["candidates"][0]["name"] == "Nergård AS"

    forced = client.post(f"{API}/companies", json={"name": "Nergård A/S", "country_code": "DK",
                                                   "allow_duplicate": True}, headers=h)
    assert forced.status_code == 201
    pairs = client.get(f"{API}/companies/duplicates", headers=h).json()
    assert len(pairs) == 1


def test_same_website_domain_is_a_duplicate(client):
    h = auth_headers("co3")
    _create(client, h, name="Alpha", websites=[{"url": "https://www.alpha-fish.example/"}])
    r = _create(client, h, name="Totally Different", websites=[{"url": "https://alpha-fish.example/jobs"}])
    assert r.status_code == 409
    assert "Same website domain" in r.json()["detail"]["candidates"][0]["reason"]


def test_verified_only_through_verify_with_source(client):
    h = auth_headers("co4")
    cid = _create(client, h).json()["id"]
    # PATCH cannot set verification fields (they are not part of the update schema).
    r = client.patch(f"{API}/companies/{cid}", json={"verification_status": "verified"}, headers=h)
    assert r.json()["verification_status"] == "user_provided"
    assert client.post(f"{API}/companies/{cid}/verify", json={}, headers=h).status_code == 422
    r = client.post(f"{API}/companies/{cid}/verify",
                    json={"source_url": "https://testfishing.example/about", "confidence": "0.9"},
                    headers=h)
    body = r.json()
    assert body["verification_status"] == "verified"
    assert body["source_url"] == "https://testfishing.example/about"
    assert body["last_verified_at"] is not None
    assert any(s["title"] == "Verified by user" for s in body["sources"])


def test_merge_moves_related_records(client):
    h = auth_headers("co5")
    a = _create(client, h, name="Samherji", country_code="IS").json()
    b = _create(client, h, name="Samherji Fishing", country_code="IS", allow_duplicate=True).json()
    client.post(f"{API}/companies/{b['id']}/contacts", json={"email": "jobs@samherji.example"},
                headers=h)
    client.post(f"{API}/companies/{b['id']}/notes", json={"body": "Ask about trawler crew"}, headers=h)
    r = client.post(f"{API}/companies/{b['id']}/merge", json={"into_id": a["id"]}, headers=h)
    assert r.status_code == 200, r.text
    merged = r.json()
    assert merged["contacts_count"] == 1
    assert merged["notes"][0]["body"] == "Ask about trawler crew"
    assert client.get(f"{API}/companies/{b['id']}", headers=h).status_code == 404
    assert [c["id"] for c in client.get(f"{API}/companies", headers=h).json()] == [a["id"]]


def test_notes_websites_sources_and_delete(client):
    h = auth_headers("co6")
    cid = _create(client, h).json()["id"]
    note = client.post(f"{API}/companies/{cid}/notes", json={"body": "first"}, headers=h).json()
    client.patch(f"{API}/companies/{cid}/notes/{note['id']}", json={"body": "edited"}, headers=h)
    client.post(f"{API}/companies/{cid}/websites", json={"url": "https://x.example/careers",
                                                         "kind": "careers"}, headers=h)
    dup = client.post(f"{API}/companies/{cid}/websites", json={"url": "https://x.example/careers"},
                      headers=h)
    assert dup.status_code == 409
    client.post(f"{API}/companies/{cid}/sources", json={"url": "https://registry.example/123",
                                                        "source_type": "business_directory"}, headers=h)
    d = client.get(f"{API}/companies/{cid}", headers=h).json()
    assert d["notes"][0]["body"] == "edited"
    assert {s["source_type"] for s in d["sources"]} == {"business_directory"}
    assert client.delete(f"{API}/companies/{cid}", headers=h).status_code == 204
    assert client.get(f"{API}/companies/{cid}", headers=h).status_code == 404


def test_companies_are_isolated_per_user(client):
    owner, other = auth_headers("co-owner"), auth_headers("co-other")
    cid = _create(client, owner).json()["id"]
    assert client.get(f"{API}/companies/{cid}", headers=other).status_code == 404
    assert client.get(f"{API}/companies", headers=other).json() == []
    # The same name is not a duplicate across different users' workspaces.
    assert _create(client, other).status_code == 201
