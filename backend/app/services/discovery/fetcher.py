"""Polite, SSRF-safe page fetcher for the discovery engine.

* http/https only; every hop (including redirects) must resolve to public IP addresses,
  so user-supplied URLs cannot reach internal services or cloud metadata endpoints;
* honours robots.txt for our user agent;
* at most one request per host per `min_interval` seconds;
* HTML only, size-capped, short timeouts; never sends cookies or credentials;
* no login, CAPTCHA or anti-bot circumvention of any kind.
"""

import ipaddress
import socket
import threading
import time
from dataclasses import dataclass
from urllib.parse import urljoin, urlsplit
from urllib.robotparser import RobotFileParser

import httpx

USER_AGENT = "SeaSpaceResearch/0.1 (personal job-search assistant; respects robots.txt)"
MAX_BYTES = 2_000_000
MAX_REDIRECTS = 4


class FetchError(Exception):
    """Safe-to-show reason a page was not fetched."""


@dataclass
class Page:
    url: str
    status: int
    html: str


class SafeFetcher:
    def __init__(self, *, allow_private_hosts: bool = False, min_interval: float = 1.0,
                 timeout: float = 10.0, transport: httpx.BaseTransport | None = None) -> None:
        self.allow_private_hosts = allow_private_hosts
        self.min_interval = min_interval
        self._client = httpx.Client(
            timeout=timeout, follow_redirects=False, transport=transport,
            headers={"User-Agent": USER_AGENT, "Accept": "text/html,application/xhtml+xml"},
        )
        self._last_hit: dict[str, float] = {}
        self._robots: dict[str, RobotFileParser | None] = {}
        self._lock = threading.Lock()

    def close(self) -> None:
        self._client.close()

    # --- safety checks --------------------------------------------------------------------

    def _check_url(self, url: str) -> None:
        parts = urlsplit(url)
        if parts.scheme not in ("http", "https") or not parts.hostname:
            raise FetchError("Only http(s) URLs can be researched")
        if parts.username or parts.password:
            raise FetchError("URLs with credentials are not allowed")
        if self.allow_private_hosts:
            return
        if parts.port not in (None, 80, 443):
            raise FetchError("Only standard web ports are allowed")
        try:
            infos = socket.getaddrinfo(parts.hostname, parts.port or 443, type=socket.SOCK_STREAM)
        except socket.gaierror as exc:
            raise FetchError(f"Host not found: {parts.hostname}") from exc
        for info in infos:
            ip = ipaddress.ip_address(info[4][0])
            if not ip.is_global:
                raise FetchError("This address is not a public website")

    def _throttle(self, host: str) -> None:
        with self._lock:
            wait = self._last_hit.get(host, 0) + self.min_interval - time.monotonic()
            self._last_hit[host] = time.monotonic() + max(wait, 0)
        if wait > 0:
            time.sleep(wait)

    def allowed_by_robots(self, url: str) -> bool:
        parts = urlsplit(url)
        origin = f"{parts.scheme}://{parts.netloc}"
        if origin not in self._robots:
            parser: RobotFileParser | None = RobotFileParser()
            try:
                robots = self._raw_get(urljoin(origin, "/robots.txt"), accept_any=True)
                if robots.status >= 500:
                    parser = None  # treat a broken robots.txt as "disallow all" (conservative)
                elif robots.status >= 400:
                    parser.parse([])  # no robots.txt → allowed
                else:
                    parser.parse(robots.html.splitlines())
            except (FetchError, httpx.HTTPError):
                parser.parse([])
            self._robots[origin] = parser
        parser = self._robots[origin]
        return parser is not None and parser.can_fetch(USER_AGENT, url)

    # --- fetching -------------------------------------------------------------------------

    def _raw_get(self, url: str, *, accept_any: bool = False) -> Page:
        for _ in range(MAX_REDIRECTS + 1):
            self._check_url(url)
            self._throttle(urlsplit(url).hostname or "")
            with self._client.stream("GET", url) as resp:
                if resp.is_redirect and "location" in resp.headers:
                    url = urljoin(url, resp.headers["location"])
                    continue
                ctype = resp.headers.get("content-type", "")
                if not accept_any and resp.status_code < 400 and "html" not in ctype:
                    raise FetchError(f"Not an HTML page ({ctype or 'unknown type'})")
                body = b""
                for chunk in resp.iter_bytes():
                    body += chunk
                    if len(body) > MAX_BYTES:
                        raise FetchError("Page is too large")
                encoding = resp.charset_encoding or "utf-8"
                return Page(url=url, status=resp.status_code,
                            html=body.decode(encoding, errors="replace"))
        raise FetchError("Too many redirects")

    def get(self, url: str) -> Page:
        if not self.allowed_by_robots(url):
            raise FetchError("robots.txt does not allow fetching this page")
        try:
            page = self._raw_get(url)
        except httpx.HTTPError as exc:
            raise FetchError(f"Could not load the page ({type(exc).__name__})") from exc
        if page.status >= 400:
            raise FetchError(f"The site answered HTTP {page.status}")
        return page
