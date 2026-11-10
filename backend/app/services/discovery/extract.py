"""Extract recruitment-relevant facts from an HTML page. Every fact keeps its source URL and
the text it came from, so the user can check it before importing anything."""

import html
import re
from dataclasses import dataclass, field
from html.parser import HTMLParser
from urllib.parse import urljoin, urlsplit

# Careers / jobs / crewing link words (EN, NO, IS, DA, NL, DE, FO, SV).
CAREER_WORDS = (
    "career", "careers", "jobs", "job", "vacanc", "recruit", "crew", "crewing", "join us",
    "work with us", "work for us", "karriere", "jobb", "ledige stillinger", "stillinger",
    "störf", "atvinna", "starv", "job hos", "ledige job", "vacatures", "werken bij", "werken",
    "stellen", "stellenangebote", "lediga jobb", "arbeid", "manning",
)
CONTACT_WORDS = ("contact", "kontakt", "hafa samband", "about", "om oss", "over ons")
SPECULATIVE_PHRASES = (
    "open application", "unsolicited application", "speculative application",
    "spontaneous application", "general application", "åpen søknad", "åben ansøgning",
    "uopfordret ansøgning", "open sollicitatie", "initiativbewerbung", "almenn umsókn",
    "send us your cv", "send your cv", "always looking for", "send oss din cv",
)
POSITION_WORDS = (
    "deckhand", "deck hand", "able seaman", " ab ", "a.b.", "matros", "fisker", "fisherman",
    "trawl", "factory", "fabrikk", "processing", "bosun", "boatswain", "háseti", "hásetar",
    "dekksmann", "krill", "crew member", "vinnslu", "fiskivinnsla", "matroos",
)
_EMAIL = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,24}")
_OBFUSCATED = re.compile(r"\s*(?:\[at\]|\(at\)|\{at\}| at )\s*", re.I)
_OBF_DOT = re.compile(r"\s*(?:\[dot\]|\(dot\)|\{dot\}| dot )\s*", re.I)
_IGNORED_EMAIL_DOMAINS = ("example.com", "sentry.io", "wixpress.com", "domain.com")


@dataclass
class Link:
    url: str
    text: str


@dataclass
class _Doc(HTMLParser):
    base: str = ""
    title: str = ""
    description: str = ""
    links: list[Link] = field(default_factory=list)
    text_parts: list[str] = field(default_factory=list)
    _in_title: bool = False
    _skip: int = 0
    _href: str | None = None
    _anchor: list[str] = field(default_factory=list)

    def __post_init__(self) -> None:
        super().__init__(convert_charrefs=True)

    def handle_starttag(self, tag, attrs):  # noqa: ANN001
        a = dict(attrs)
        if tag in ("script", "style", "noscript", "svg"):
            self._skip += 1
        elif tag == "title":
            self._in_title = True
        elif tag == "meta" and (a.get("name") or "").lower() in ("description", "og:description"):
            self.description = self.description or (a.get("content") or "").strip()
        elif tag == "a" and a.get("href"):
            self._href = a["href"]
            self._anchor = []
        elif tag in ("br", "p", "div", "li", "tr", "h1", "h2", "h3", "h4"):
            self.text_parts.append("\n")

    def handle_endtag(self, tag):  # noqa: ANN001
        if tag in ("script", "style", "noscript", "svg") and self._skip:
            self._skip -= 1
        elif tag == "title":
            self._in_title = False
        elif tag == "a" and self._href is not None:
            self.links.append(Link(urljoin(self.base, self._href.strip()),
                                   " ".join("".join(self._anchor).split())))
            self._href = None

    def handle_data(self, data):  # noqa: ANN001
        if self._skip:
            return
        if self._in_title:
            self.title += data
        if self._href is not None:
            self._anchor.append(data)
        self.text_parts.append(data)


@dataclass
class PageFacts:
    url: str
    title: str
    description: str
    text: str
    emails: list[tuple[str, str]]  # (email, surrounding text)
    career_links: list[Link]
    contact_links: list[Link]
    speculative_evidence: list[str]
    position_mentions: list[str]


def _context(text: str, needle: str, width: int = 90) -> str:
    i = text.lower().find(needle.lower())
    if i < 0:
        return ""
    snippet = text[max(0, i - width): i + len(needle) + width]
    return " ".join(snippet.split())


def parse_page(url: str, raw_html: str) -> PageFacts:
    doc = _Doc(base=url)
    doc.feed(raw_html)
    text = html.unescape("".join(doc.text_parts))
    text = re.sub(r"[ \t\r\f\v]+", " ", text)
    site_host = (urlsplit(url).hostname or "").removeprefix("www.")

    emails: dict[str, str] = {}
    for link in doc.links:
        if link.url.lower().startswith("mailto:"):
            addr = link.url[7:].split("?")[0].strip()
            if _EMAIL.fullmatch(addr):
                emails.setdefault(addr.lower(), _context(text, link.text or addr) or link.text)
    deobfuscated = _OBF_DOT.sub(".", _OBFUSCATED.sub("@", text))
    for m in _EMAIL.finditer(deobfuscated):
        addr = m.group(0).strip(".").lower()
        if addr.endswith(_IGNORED_EMAIL_DOMAINS) or addr.endswith((".png", ".jpg", ".gif")):
            continue
        emails.setdefault(addr, " ".join(deobfuscated[max(0, m.start() - 90): m.end() + 90].split()))

    def same_site(link: Link) -> bool:
        host = (urlsplit(link.url).hostname or "").removeprefix("www.")
        return host == site_host or host.endswith("." + site_host) or site_host.endswith("." + host)

    def matching(words: tuple[str, ...]) -> list[Link]:
        seen, out = set(), []
        for link in doc.links:
            hay = f" {link.text.lower()} {link.url.lower()} "
            if link.url.startswith(("http://", "https://")) and any(w in hay for w in words):
                key = link.url.split("#")[0]
                if key not in seen:
                    seen.add(key)
                    out.append(Link(key, link.text))
        return out

    career_links = [lnk for lnk in matching(CAREER_WORDS) if same_site(lnk)][:8]
    # External job portals (e.g. a recruitment SaaS) are still useful but listed separately.
    career_links += [lnk for lnk in matching(CAREER_WORDS) if not same_site(lnk)][:4]
    contact_links = [lnk for lnk in matching(CONTACT_WORDS) if same_site(lnk)][:4]

    low = f" {text.lower()} "
    speculative = [_context(text, p) for p in SPECULATIVE_PHRASES if p in low]
    positions = sorted({p.strip() for p in POSITION_WORDS if p in low})
    return PageFacts(
        url=url, title=" ".join(doc.title.split()), description=doc.description,
        text=text, emails=list(emails.items()), career_links=career_links,
        contact_links=contact_links, speculative_evidence=[s for s in speculative if s][:5],
        position_mentions=positions,
    )
