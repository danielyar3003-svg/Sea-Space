"""Discovery sources.

Each source returns *findings* with the exact source URL and excerpt. Nothing is written to
the user's database here: the user reviews findings and imports what they choose.
"""

from dataclasses import asdict, dataclass, field
from datetime import UTC, datetime
from typing import Literal

import httpx

from app.services.discovery.extract import PageFacts, parse_page
from app.services.discovery.fetcher import FetchError, SafeFetcher
from app.services.normalize import (
    email_domain,
    is_generic_mailbox,
    is_recruitment_mailbox,
    registrable_domain,
)

FindingKind = Literal["email", "careers_page", "contact_page", "speculative_policy",
                      "position_mention", "company_profile", "search_result"]


@dataclass
class Finding:
    kind: FindingKind
    value: str
    source_url: str
    excerpt: str = ""
    # Machine hints for the UI; never a verification claim.
    hints: dict = field(default_factory=dict)


@dataclass
class ResearchReport:
    start_url: str
    pages_checked: list[str]
    pages_skipped: list[dict]
    findings: list[Finding]
    checked_at: str
    limitations: list[str]

    def to_dict(self) -> dict:
        return asdict(self)


MAX_PAGES = 4


def research_website(url: str, fetcher: SafeFetcher) -> ResearchReport:
    """Read a company's own website: home page + up to three careers/contact pages."""
    findings: list[Finding] = []
    checked: list[str] = []
    skipped: list[dict] = []
    site_domain = registrable_domain(url)

    def visit(page_url: str) -> PageFacts | None:
        try:
            page = fetcher.get(page_url)
        except FetchError as exc:
            skipped.append({"url": page_url, "reason": str(exc)})
            return None
        checked.append(page.url)
        return parse_page(page.url, page.html)

    home = visit(url)
    if home is None:
        return ResearchReport(url, checked, skipped, [], _now(), _limitations(0))
    findings.append(Finding("company_profile", home.title or url, home.url, home.description))

    queue = [lnk.url for lnk in home.career_links] + [lnk.url for lnk in home.contact_links]
    pages = [home]
    for next_url in dict.fromkeys(queue):
        if len(checked) + len(skipped) >= MAX_PAGES:
            break
        if registrable_domain(next_url) != site_domain:
            continue  # only the company's own site is crawled; external portals are listed
        facts = visit(next_url)
        if facts:
            pages.append(facts)

    seen_emails: set[str] = set()
    for facts in pages:
        for addr, excerpt in facts.emails:
            if addr in seen_emails:
                continue
            seen_emails.add(addr)
            findings.append(Finding("email", addr, facts.url, excerpt, hints={
                "generic_inbox": is_generic_mailbox(addr),
                "recruitment_inbox": is_recruitment_mailbox(addr),
                "domain_matches_site": email_domain(addr) == site_domain,
            }))
        for link in facts.career_links:
            findings.append(Finding("careers_page", link.url, facts.url, link.text, hints={
                "external_portal": registrable_domain(link.url) != site_domain}))
        for link in facts.contact_links:
            findings.append(Finding("contact_page", link.url, facts.url, link.text))
        for ev in facts.speculative_evidence:
            findings.append(Finding("speculative_policy", ev, facts.url, ev))
        for pos in facts.position_mentions:
            findings.append(Finding("position_mention", pos, facts.url,
                                    _snippet(facts.text, pos)))

    findings = _dedupe(findings)
    return ResearchReport(url, checked, skipped, findings, _now(), _limitations(len(checked)))


def _snippet(text: str, needle: str) -> str:
    i = text.lower().find(needle)
    return " ".join(text[max(0, i - 80): i + 80].split()) if i >= 0 else ""


def _dedupe(items: list[Finding]) -> list[Finding]:
    seen, out = set(), []
    for f in items:
        key = (f.kind, f.value)
        if key not in seen:
            seen.add(key)
            out.append(f)
    return out


def _now() -> str:
    return datetime.now(UTC).isoformat()


def _limitations(pages: int) -> list[str]:
    return [
        f"Only {pages} page(s) of this website were read; other pages may have more information.",
        "E-mails are shown exactly as published. Confirm each one before marking it verified.",
        "Mentions of positions are keywords on the page, not confirmed open vacancies.",
    ]


# --- Search API source -----------------------------------------------------------------------


class SearchNotConfigured(Exception):
    pass


def web_search(query: str, api_key: str | None, *, count: int = 10,
               transport: httpx.BaseTransport | None = None) -> list[Finding]:
    """Brave Search API. Results are search snippets: shown as leads, never as confirmed facts."""
    if not api_key:
        raise SearchNotConfigured("Search API is not configured (BRAVE_SEARCH_API_KEY)")
    with httpx.Client(timeout=10, transport=transport) as client:
        resp = client.get(
            "https://api.search.brave.com/res/v1/web/search",
            params={"q": query, "count": min(count, 20), "safesearch": "moderate"},
            headers={"Accept": "application/json", "X-Subscription-Token": api_key},
        )
    if resp.status_code == 401:
        raise SearchNotConfigured("Search API key was rejected")
    resp.raise_for_status()
    results = resp.json().get("web", {}).get("results", [])
    return [
        Finding("search_result", r.get("title") or r["url"], r["url"],
                r.get("description", ""), hints={"snippet_only": True})
        for r in results if r.get("url")
    ]


# --- Research targets from the product brief ------------------------------------------------

# Starting points named in the brief. Only names are given: country, website and hiring
# status are deliberately left empty until the user researches and verifies them.
RESEARCH_TARGETS = [
    "Cornelis Vrolijk",
    "Aker BioMarine",
    "Nergård",
    "Samherji",
    "Qrill Company",
    "HAV Agency",
]
