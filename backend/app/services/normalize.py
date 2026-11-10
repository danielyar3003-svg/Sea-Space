"""Name / URL / identifier normalisation used for duplicate detection and validation."""

import re
import unicodedata
from difflib import SequenceMatcher
from urllib.parse import urlsplit

_TRANSLIT = str.maketrans({
    "æ": "ae", "ø": "o", "å": "a", "ð": "d", "þ": "th", "ß": "ss", "œ": "oe", "ł": "l",
})

# Legal-form suffixes common in the target markets (Nordics, Benelux, Germany, UK).
_LEGAL_FORMS = {
    "as", "asa", "ab", "ehf", "hf", "sf", "aps", "a s", "a/s", "bv", "b v", "nv", "n v",
    "gmbh", "kg", "ag", "ltd", "limited", "plc", "llc", "inc", "oy", "oyj", "sa", "sp f",
    "p f", "pf", "co", "company", "group", "holding", "holdings",
}


def normalize_company_name(name: str) -> str:
    """'Nergård AS' → 'nergard'; 'Cornelis Vrolijk B.V.' → 'cornelis vrolijk'."""
    s = name.strip().lower().translate(_TRANSLIT)
    s = unicodedata.normalize("NFKD", s)
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = re.sub(r"[^a-z0-9/ ]+", " ", s.replace(".", ""))
    s = re.sub(r"\s+", " ", s).strip()
    words = s.split(" ")
    while len(words) > 1 and (words[-1] in _LEGAL_FORMS or " ".join(words[-2:]) in _LEGAL_FORMS):
        words = words[:-2] if " ".join(words[-2:]) in _LEGAL_FORMS else words[:-1]
    # Faroese / Danish prefixes such as "P/F", "Sp/f".
    if len(words) > 1 and words[0] in {"p/f", "sp/f"}:
        words = words[1:]
    return " ".join(words).replace("/", " ").strip() or s


def name_similarity(a: str, b: str) -> float:
    return SequenceMatcher(None, a, b).ratio()


def registrable_domain(url_or_host: str | None) -> str | None:
    """Very small eTLD+1 approximation, good enough for comparing company sites/e-mails."""
    if not url_or_host:
        return None
    host = urlsplit(url_or_host if "//" in url_or_host else f"//{url_or_host}").hostname
    if not host:
        return None
    host = host.lower().removeprefix("www.")
    parts = host.split(".")
    if len(parts) >= 3 and parts[-2] in {"co", "com", "org", "net", "ac"} and len(parts[-1]) == 2:
        return ".".join(parts[-3:])
    return ".".join(parts[-2:]) if len(parts) >= 2 else host


def email_domain(email: str | None) -> str | None:
    if not email or "@" not in email:
        return None
    return registrable_domain(email.rsplit("@", 1)[1])


def is_valid_imo(imo: str) -> bool:
    """IMO ship number: 7 digits, last digit is a weighted checksum."""
    if not re.fullmatch(r"\d{7}", imo):
        return False
    digits = [int(d) for d in imo]
    return sum(d * w for d, w in zip(digits[:6], range(7, 1, -1), strict=True)) % 10 == digits[6]


GENERIC_MAILBOX_PREFIXES = (
    "jobs", "job", "career", "careers", "crew", "crewing", "hr", "recruit", "recruitment",
    "rekruttering", "jobb", "personal", "personnel", "manning", "apply", "vacancy",
    "vacancies", "work", "info", "post", "office", "mail", "contact", "kontakt",
)


def is_generic_mailbox(email: str) -> bool:
    local = email.split("@", 1)[0].lower()
    return any(local == p or local.startswith(p + ".") or local.startswith(p + "-")
               for p in GENERIC_MAILBOX_PREFIXES)


RECRUITMENT_MAILBOX_PREFIXES = ("jobs", "job", "career", "careers", "crew", "crewing", "hr",
                                "recruit", "recruitment", "rekruttering", "jobb", "manning",
                                "personnel", "apply", "vacancy", "vacancies")


def is_recruitment_mailbox(email: str) -> bool:
    local = email.split("@", 1)[0].lower()
    return any(local.startswith(p) for p in RECRUITMENT_MAILBOX_PREFIXES)
