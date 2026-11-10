import functools
import threading
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

import pytest

from app.services.discovery.fetcher import FetchError, SafeFetcher
from app.services.normalize import is_valid_imo, normalize_company_name
from tests.conftest import auth_headers

API = "/api/v1"
SITE = Path(__file__).parent / "fixtures" / "site"


@pytest.fixture(scope="module")
def site_url():
    handler = functools.partial(SimpleHTTPRequestHandler, directory=str(SITE))
    handler.log_message = lambda *a, **k: None
    server = ThreadingHTTPServer(("127.0.0.1", 0), handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    yield f"http://127.0.0.1:{server.server_address[1]}"
    server.shutdown()


def test_normalisation_helpers():
    assert normalize_company_name("Nergård AS") == "nergard"
    assert normalize_company_name("Cornelis Vrolijk B.V.") == "cornelis vrolijk"
    assert normalize_company_name("P/F Varðin") == "vardin"
    assert is_valid_imo("9074729") and not is_valid_imo("9074728")


def test_ssrf_protection_blocks_internal_addresses():
    fetcher = SafeFetcher(allow_private_hosts=False)
    for url in ("http://127.0.0.1/", "http://localhost:8000/", "http://169.254.169.254/latest/",
                "file:///etc/passwd", "ftp://example.com/", "http://user:pw@example.com/"):
        with pytest.raises(FetchError):
            fetcher.get(url)


def test_website_research_finds_sourced_facts(client, site_url):
    h = auth_headers("disc1")
    r = client.post(f"{API}/discovery/website", json={"url": site_url + "/"}, headers=h)
    assert r.status_code == 200, r.text
    report = r.json()
    by_kind: dict[str, list] = {}
    for f in report["findings"]:
        by_kind.setdefault(f["kind"], []).append(f)

    emails = {f["value"]: f for f in by_kind["email"]}
    assert set(emails) == {"crewing@nordhav.test", "ola.nordmann@nordhav.test"}
    assert emails["crewing@nordhav.test"]["source_url"].endswith("/careers/")
    assert emails["crewing@nordhav.test"]["hints"]["recruitment_inbox"] is True
    assert "ignored@example.com" not in emails  # scripts are not read

    assert any(f["value"].endswith("/careers/") for f in by_kind["careers_page"])
    portal = [f for f in by_kind["careers_page"] if "portal.example-jobs.test" in f["value"]]
    assert portal and portal[0]["hints"]["external_portal"] is True
    assert by_kind["speculative_policy"]
    assert {"deckhand", "factory"} <= {f["value"] for f in by_kind["position_mention"]}

    # robots.txt: /private/ is never fetched; external portal is listed, not crawled.
    assert not any("/private/" in p for p in report["pages_checked"])
    assert not any("portal.example-jobs.test" in p for p in report["pages_checked"])
    assert len(report["pages_checked"]) <= 4
    assert report["limitations"]


def test_robots_disallow_is_respected(client, site_url):
    r = client.post(f"{API}/discovery/website", json={"url": site_url + "/private/secret.html"},
                    headers=auth_headers("disc2"))
    assert r.status_code == 200
    assert r.json()["findings"] == []
    assert "robots.txt" in r.json()["pages_skipped"][0]["reason"]


def test_import_finding_creates_unverified_contact(client, site_url):
    h = auth_headers("disc3")
    cid = client.post(f"{API}/companies", json={"name": "Nordhav Fishing AS"}, headers=h).json()["id"]
    report = client.post(f"{API}/discovery/website", json={"url": site_url + "/", "company_id": cid},
                         headers=h).json()
    email = next(f for f in report["findings"] if f["value"] == "crewing@nordhav.test")
    r = client.post(f"{API}/discovery/import", headers=h, json={
        "company_id": cid, "kind": "email", "value": email["value"],
        "source_url": email["source_url"], "excerpt": email["excerpt"]})
    assert r.status_code == 201, r.text
    contact = client.get(f"{API}/contacts?company_id={cid}", headers=h).json()[0]
    assert contact["contact_kind"] == "generic_inbox"
    assert contact["verification_status"] == "unverified"
    assert contact["source_url"] == email["source_url"]

    careers = next(f for f in report["findings"] if f["kind"] == "careers_page")
    client.post(f"{API}/discovery/import", headers=h, json={
        "company_id": cid, "kind": "careers_page", "value": careers["value"],
        "source_url": careers["source_url"]})
    spec = next(f for f in report["findings"] if f["kind"] == "speculative_policy")
    client.post(f"{API}/discovery/import", headers=h, json={
        "company_id": cid, "kind": "speculative_policy", "value": spec["value"],
        "source_url": spec["source_url"]})
    company = client.get(f"{API}/companies/{cid}", headers=h).json()
    assert company["careers_url"] == careers["value"]
    assert company["hiring_status"] == "speculative_accepted"
    assert any(s["source_type"] == "official_website" for s in company["sources"])


def test_research_targets_import_is_idempotent(client):
    h = auth_headers("disc4")
    targets = client.get(f"{API}/discovery/targets", headers=h).json()
    assert {t["name"] for t in targets} >= {"Aker BioMarine", "Samherji", "Nergård"}
    assert all(t["company_id"] is None for t in targets)
    first = client.post(f"{API}/discovery/targets/import", headers=h).json()
    second = client.post(f"{API}/discovery/targets/import", headers=h).json()
    assert all(t["company_id"] for t in first) and first == second
    companies = client.get(f"{API}/companies", headers=h).json()
    assert len(companies) == len(targets)
    # Only names are known: nothing else is invented.
    assert all(c["country_code"] is None and c["hiring_status"] == "unknown" for c in companies)


def test_search_reports_not_configured(client):
    r = client.post(f"{API}/discovery/search", json={"query": "trawler crew Norway"},
                    headers=auth_headers("disc5"))
    assert r.status_code == 503
    assert "not configured" in r.json()["detail"]
