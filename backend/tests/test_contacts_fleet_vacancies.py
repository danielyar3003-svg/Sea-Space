from datetime import date, timedelta

import pytest
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError

from app.db.session import get_engine
from tests.conftest import auth_headers

API = "/api/v1"


def _company(client, h, name="Hav Test AS", site="https://havtest.example/"):
    r = client.post(f"{API}/companies", json={"name": name, "websites": [{"url": site}]}, headers=h)
    assert r.status_code == 201, r.text
    return r.json()["id"]


# --- Contacts ---------------------------------------------------------------------------------


def test_contact_lifecycle_and_filters(client):
    h = auth_headers("ct1")
    cid = _company(client, h)
    generic = client.post(f"{API}/companies/{cid}/contacts", headers=h, json={
        "contact_kind": "generic_inbox", "email": "crew@havtest.example",
        "source_url": "https://havtest.example/careers"}).json()
    assert generic["email_status"] == "public_unverified"
    assert generic["verification_status"] == "unverified"
    assert generic["domain_matches_company"] is True

    person = client.post(f"{API}/companies/{cid}/contacts", headers=h, json={
        "full_name": "Kari Nordmann", "job_title": "Crewing Manager",
        "email": "kari@gmail.example"}).json()
    assert person["domain_matches_company"] is False  # flagged: not the company's domain

    dup = client.post(f"{API}/companies/{cid}/contacts", headers=h, json={"email": "crew@havtest.example"})
    assert dup.status_code == 409

    def ids(f):
        return {c["id"] for c in client.get(f"{API}/contacts?filter={f}", headers=h).json()}

    assert ids("generic") == {generic["id"]}
    assert ids("people") == {person["id"]}
    assert ids("verified") == set()

    v = client.post(f"{API}/contacts/{generic['id']}/verify", headers=h,
                    json={"source_url": "https://havtest.example/careers"}).json()
    assert v["verification_status"] == "verified" and v["email_status"] == "public_verified"
    assert ids("verified") == {generic["id"]}

    # Changing a verified e-mail drops the verification.
    changed = client.patch(f"{API}/contacts/{generic['id']}", headers=h,
                           json={"email": "jobs@havtest.example"}).json()
    assert changed["verification_status"] == "unverified"


def test_inferred_email_can_never_be_verified(client):
    h = auth_headers("ct2")
    cid = _company(client, h)
    c = client.post(f"{API}/companies/{cid}/contacts", headers=h, json={
        "full_name": "Guess Person", "email": "guess.person@havtest.example",
        "email_status": "inferred"}).json()
    r = client.post(f"{API}/contacts/{c['id']}/verify", headers=h,
                    json={"source_url": "https://havtest.example/team"})
    assert r.status_code == 422
    assert {x["id"] for x in client.get(f"{API}/contacts?filter=inferred", headers=h).json()} == {c["id"]}
    # The database refuses it too, even if application code had a bug.
    with pytest.raises(DBAPIError), get_engine().begin() as conn:
        conn.execute(text(
            "UPDATE company_contacts SET verification_status='verified', "
            "source_url='https://x.example', last_verified_at=now() WHERE id=:id"), {"id": c["id"]})


# --- Fleet ------------------------------------------------------------------------------------


def test_vessels_imo_and_owner_operator_links(client):
    h = auth_headers("fl1")
    owner = _company(client, h, "Owner Holding AS", "https://owner.example/")
    operator = _company(client, h, "Operator Fishing AS", "https://operator.example/")
    types = client.get(f"{API}/vessel-types", headers=h).json()
    krill = next(t for t in types if t["code"] == "krill_trawler")

    bad = client.post(f"{API}/vessels", headers=h, json={"name": "Bad", "imo_number": "9074728"})
    assert bad.status_code == 422
    v = client.post(f"{API}/vessels", headers=h, json={
        "name": "Test Trawler", "imo_number": "9074729", "flag_country_code": "no",
        "vessel_type_id": krill["id"]}).json()
    assert v["flag_country_code"] == "NO"
    assert "Processing Crew" in v["potential_positions"]
    dup = client.post(f"{API}/vessels", headers=h, json={"name": "Copy", "imo_number": "9074729"})
    assert dup.status_code == 409

    client.post(f"{API}/vessels/{v['id']}/links", headers=h, json={"company_id": owner, "role": "owner"})
    r = client.post(f"{API}/vessels/{v['id']}/links", headers=h, json={
        "company_id": operator, "role": "operator", "is_crewing_employer": None})
    links = r.json()["links"]
    assert {(lnk["role"], lnk["company_name"]) for lnk in links} == {
        ("owner", "Owner Holding AS"), ("operator", "Operator Fishing AS")}
    op_link = next(lnk for lnk in links if lnk["role"] == "operator")
    assert op_link["is_crewing_employer"] is None  # unknown, not assumed

    by_operator = client.get(f"{API}/vessels?company_id={operator}", headers=h).json()
    assert [x["id"] for x in by_operator] == [v["id"]]
    company = client.get(f"{API}/companies/{owner}", headers=h).json()
    assert company["vessels"][0]["vessel_name"] == "Test Trawler"


# --- Vacancies --------------------------------------------------------------------------------


def test_vacancy_states(client):
    h = auth_headers("vc1")
    cid = _company(client, h)
    body = {"company_id": cid, "employer_name": "Hav Test AS", "position": "Trawl Deckhand",
            "source_url": "https://havtest.example/jobs/1", "salary_min": "3000",
            "salary_max": "4000", "currency": "EUR", "salary_period": "monthly"}
    v = client.post(f"{API}/vacancies", headers=h, json=body).json()
    assert v["status"] == "unverified"  # never 'active' just because it was found
    assert client.post(f"{API}/vacancies", headers=h, json=body).status_code == 409
    assert client.post(f"{API}/vacancies/{v['id']}/verify", headers=h).json()["status"] == "active"
    assert client.get(f"{API}/companies/{cid}", headers=h).json()["open_vacancies_count"] == 1

    bad = client.post(f"{API}/vacancies", headers=h, json={**body, "source_url": "https://x.example/2",
                                                           "salary_min": "5000", "salary_max": "100"})
    assert bad.status_code == 422

    old = client.post(f"{API}/vacancies", headers=h, json={
        **body, "source_url": "https://havtest.example/jobs/old",
        "application_deadline": str(date.today() - timedelta(days=1))}).json()
    listed = {x["id"]: x["status"] for x in client.get(f"{API}/vacancies", headers=h).json()}
    assert listed[old["id"]] == "expired"
    assert client.post(f"{API}/vacancies/{old['id']}/verify", headers=h).status_code == 422
    assert [x["id"] for x in client.get(f"{API}/vacancies?status=active", headers=h).json()] == [v["id"]]
