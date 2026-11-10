"""Allowed values for constrained string columns (stored as VARCHAR + CHECK)."""

from enum import StrEnum


class HiringStatus(StrEnum):
    ACTIVELY_HIRING = "actively_hiring"
    NO_CURRENT_VACANCIES = "no_current_vacancies"
    SPECULATIVE_ACCEPTED = "speculative_accepted"
    RECRUITMENT_AGENCY = "recruitment_agency"
    UNKNOWN = "unknown"


class Industry(StrEnum):
    FISHING = "fishing"
    TRAWLING = "trawling"
    KRILL = "krill"
    SEAFOOD_PROCESSING = "seafood_processing"
    FACTORY_VESSEL = "factory_vessel"
    RECRUITMENT_AGENCY = "recruitment_agency"
    SHIP_MANAGEMENT = "ship_management"
    OTHER = "other"


class ApplicationStatus(StrEnum):
    DISCOVERED = "discovered"
    RESEARCHED = "researched"
    READY_TO_CONTACT = "ready_to_contact"
    DRAFT_CREATED = "draft_created"
    SENT = "sent"
    WAITING_FOR_REPLY = "waiting_for_reply"
    FOLLOW_UP_NEEDED = "follow_up_needed"
    REPLIED = "replied"
    INTERVIEW = "interview"
    OFFER = "offer"
    HIRED = "hired"
    REJECTED = "rejected"
    NO_VACANCIES = "no_vacancies"
    KEEP_IN_TOUCH = "keep_in_touch"


class ContactKind(StrEnum):
    PERSON = "person"
    GENERIC_INBOX = "generic_inbox"


class EmailStatus(StrEnum):
    """How we know the email address. Inferred addresses are never shown as verified."""

    PUBLIC_VERIFIED = "public_verified"
    PUBLIC_UNVERIFIED = "public_unverified"
    INFERRED = "inferred"
    USER_PROVIDED = "user_provided"


class ContactStatus(StrEnum):
    NEW = "new"
    CONTACTED = "contacted"
    REPLIED = "replied"
    BOUNCED = "bounced"
    DO_NOT_CONTACT = "do_not_contact"


class VacancyStatus(StrEnum):
    ACTIVE = "active"
    EXPIRED = "expired"
    UNVERIFIED = "unverified"


class PayPeriod(StrEnum):
    HOURLY = "hourly"
    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"
    PER_TRIP = "per_trip"
    YEARLY = "yearly"


class DocumentCategory(StrEnum):
    CV = "cv"
    SEAMANS_BOOK = "seamans_book"
    PASSPORT = "passport"
    MEDICAL = "medical"
    STCW = "stcw"
    ENDORSEMENT = "endorsement"
    SEA_SERVICE = "sea_service"
    RECOMMENDATION = "recommendation"
    OTHER_CERTIFICATE = "other_certificate"
    OTHER = "other"


class EnglishLevel(StrEnum):
    BEGINNER = "beginner"
    ELEMENTARY = "elementary"
    INTERMEDIATE = "intermediate"
    UPPER_INTERMEDIATE = "upper_intermediate"
    ADVANCED = "advanced"
    FLUENT = "fluent"


class EmailDirection(StrEnum):
    INBOUND = "inbound"
    OUTBOUND = "outbound"


class ThreadAssociation(StrEnum):
    """Email ↔ company/application links are never silent: suggested until confirmed."""

    UNLINKED = "unlinked"
    SUGGESTED = "suggested"
    CONFIRMED = "confirmed"
    REJECTED = "rejected"


class DraftStatus(StrEnum):
    DRAFT = "draft"
    APPROVED = "approved"
    DISCARDED = "discarded"
    SENT = "sent"


class DraftKind(StrEnum):
    EMAIL = "email"
    COVER_LETTER = "cover_letter"
    CV = "cv"
    REPLY = "reply"
    FOLLOW_UP = "follow_up"


def values(enum_cls: type[StrEnum]) -> tuple[str, ...]:
    return tuple(m.value for m in enum_cls)
