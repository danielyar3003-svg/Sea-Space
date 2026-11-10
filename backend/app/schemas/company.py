import uuid
from datetime import date, datetime
from decimal import Decimal
from typing import Annotated, Literal

from pydantic import AnyHttpUrl, BaseModel, BeforeValidator, ConfigDict, EmailStr, Field

from app.models.enums import (
    ContactKind,
    ContactStatus,
    EmailStatus,
    HiringStatus,
    Industry,
    PayPeriod,
    VacancyStatus,
)

Url = AnyHttpUrl
Country = Annotated[
    str,
    BeforeValidator(lambda v: v.strip().upper() if isinstance(v, str) else v),
    Field(min_length=2, max_length=2, pattern=r"^[A-Z]{2}$", description="ISO 3166-1 alpha-2"),
]


class Provenance(BaseModel):
    """Read-only provenance block. `verified` is only ever set through a /verify endpoint."""

    model_config = ConfigDict(from_attributes=True)

    source_url: str | None
    verification_status: str
    last_verified_at: datetime | None
    confidence: Decimal | None


class VerifyIn(BaseModel):
    source_url: Url
    confidence: Decimal | None = Field(default=None, ge=0, le=1)


# --- Companies ----------------------------------------------------------------------------

WebsiteKind = Literal["main", "careers", "fleet", "contact", "other"]


class WebsiteIn(BaseModel):
    url: Url
    kind: WebsiteKind = "main"


class WebsiteOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    url: str
    kind: str


class CompanyBase(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    country_code: Country | None = None
    headquarters: str | None = Field(default=None, max_length=255)
    hiring_status: HiringStatus = HiringStatus.UNKNOWN
    speculative_policy: str | None = Field(default=None, max_length=5000)
    careers_url: Url | None = None
    recruitment_email: EmailStr | None = None
    fleet_summary: str | None = Field(default=None, max_length=5000)
    description: str | None = Field(default=None, max_length=10000)
    latitude: Decimal | None = Field(default=None, ge=-90, le=90)
    longitude: Decimal | None = Field(default=None, ge=-180, le=180)


class CompanyCreate(CompanyBase):
    industries: list[Industry] = Field(default_factory=list, max_length=8)
    websites: list[WebsiteIn] = Field(default_factory=list, max_length=10)
    source_url: Url | None = None
    # Create even when a likely duplicate exists (the user reviewed the warning).
    allow_duplicate: bool = False


class CompanyUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=255)
    country_code: Country | None = None
    headquarters: str | None = Field(default=None, max_length=255)
    hiring_status: HiringStatus | None = None
    speculative_policy: str | None = Field(default=None, max_length=5000)
    careers_url: Url | None = None
    recruitment_email: EmailStr | None = None
    fleet_summary: str | None = Field(default=None, max_length=5000)
    description: str | None = Field(default=None, max_length=10000)
    latitude: Decimal | None = Field(default=None, ge=-90, le=90)
    longitude: Decimal | None = Field(default=None, ge=-180, le=180)
    industries: list[Industry] | None = Field(default=None, max_length=8)


class CompanySummary(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    name: str
    country_code: str | None
    headquarters: str | None
    hiring_status: str
    verification_status: str
    last_verified_at: datetime | None
    industries: list[str] = []
    contacts_count: int = 0
    open_vacancies_count: int = 0
    created_at: datetime
    updated_at: datetime


class SourceIn(BaseModel):
    url: Url | None = None
    title: str | None = Field(default=None, max_length=500)
    source_type: Literal[
        "official_website", "careers_page", "business_directory", "fleet_registry",
        "recruitment_page", "search_api", "publication", "professional_profile",
        "user_entry", "other",
    ] = "user_entry"
    excerpt: str | None = Field(default=None, max_length=5000)
    fields_supported: list[str] = Field(default_factory=list, max_length=30)


class SourceOut(SourceIn):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    url: str | None = None
    retrieved_at: datetime


class NoteIn(BaseModel):
    body: str = Field(min_length=1, max_length=20000)


class NoteOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    body: str
    created_at: datetime
    updated_at: datetime


class CompanyDetail(CompanySummary, Provenance):
    speculative_policy: str | None
    careers_url: str | None
    recruitment_email: str | None
    fleet_summary: str | None
    description: str | None
    latitude: Decimal | None
    longitude: Decimal | None
    websites: list[WebsiteOut] = []
    sources: list[SourceOut] = []
    notes: list[NoteOut] = []
    vessels: list["VesselLink"] = []


class DuplicateCandidate(BaseModel):
    id: uuid.UUID
    name: str
    country_code: str | None
    reason: str
    score: float


class DuplicatePair(BaseModel):
    a: DuplicateCandidate
    b: DuplicateCandidate


class MergeIn(BaseModel):
    into_id: uuid.UUID


# --- Contacts -----------------------------------------------------------------------------


class ContactBase(BaseModel):
    contact_kind: ContactKind = ContactKind.PERSON
    full_name: str | None = Field(default=None, max_length=200)
    job_title: str | None = Field(default=None, max_length=200)
    email: EmailStr | None = None
    email_status: EmailStatus | None = None
    phone: str | None = Field(default=None, max_length=50)
    linkedin_url: Url | None = None
    contact_status: ContactStatus = ContactStatus.NEW


class ContactCreate(ContactBase):
    source_url: Url | None = None


class ContactUpdate(BaseModel):
    contact_kind: ContactKind | None = None
    full_name: str | None = Field(default=None, max_length=200)
    job_title: str | None = Field(default=None, max_length=200)
    email: EmailStr | None = None
    email_status: EmailStatus | None = None
    phone: str | None = Field(default=None, max_length=50)
    linkedin_url: Url | None = None
    contact_status: ContactStatus | None = None


class ContactOut(ContactBase, Provenance):
    id: uuid.UUID
    company_id: uuid.UUID
    company_name: str | None = None
    email: str | None = None
    linkedin_url: str | None = None
    domain_matches_company: bool | None = None
    created_at: datetime
    updated_at: datetime


# --- Fleet --------------------------------------------------------------------------------


class VesselTypeOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    code: str
    name: str
    category: str
    typical_positions: list[str]


class VesselBase(BaseModel):
    name: str = Field(min_length=1, max_length=200)
    imo_number: str | None = Field(default=None, pattern=r"^\d{7}$")
    flag_country_code: Country | None = None
    vessel_type_id: uuid.UUID | None = None
    fishing_specialization: str | None = Field(default=None, max_length=200)
    home_country_code: Country | None = None
    notes: str | None = Field(default=None, max_length=5000)


class VesselCreate(VesselBase):
    source_url: Url | None = None


class VesselUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=200)
    imo_number: str | None = Field(default=None, pattern=r"^\d{7}$")
    flag_country_code: Country | None = None
    vessel_type_id: uuid.UUID | None = None
    fishing_specialization: str | None = Field(default=None, max_length=200)
    home_country_code: Country | None = None
    notes: str | None = Field(default=None, max_length=5000)


class VesselLinkIn(BaseModel):
    company_id: uuid.UUID
    role: Literal["owner", "operator"]
    valid_from: date | None = None
    valid_to: date | None = None
    is_crewing_employer: bool | None = None  # operators only; None = unknown
    source_url: Url | None = None


class VesselLink(BaseModel):
    id: uuid.UUID
    role: str
    vessel_id: uuid.UUID
    vessel_name: str
    company_id: uuid.UUID
    company_name: str
    valid_from: date | None
    valid_to: date | None
    is_crewing_employer: bool | None = None
    verification_status: str
    source_url: str | None


class VesselOut(VesselBase, Provenance):
    id: uuid.UUID
    vessel_type: VesselTypeOut | None = None
    links: list[VesselLink] = []
    potential_positions: list[str] = []
    created_at: datetime
    updated_at: datetime


# --- Vacancies ----------------------------------------------------------------------------


class VacancyBase(BaseModel):
    company_id: uuid.UUID | None = None
    employer_name: str = Field(min_length=1, max_length=255)
    position: str = Field(min_length=1, max_length=200)
    country_code: Country | None = None
    vessel_type: str | None = Field(default=None, max_length=100)
    salary_min: Decimal | None = Field(default=None, ge=0)
    salary_max: Decimal | None = Field(default=None, ge=0)
    currency: str | None = Field(default=None, pattern=r"^[A-Z]{3}$")
    salary_period: PayPeriod | None = None
    contract_duration: str | None = Field(default=None, max_length=100)
    rotation: str | None = Field(default=None, max_length=100)
    requirements: str | None = Field(default=None, max_length=10000)
    application_deadline: date | None = None
    source_url: Url


class VacancyCreate(VacancyBase):
    pass


class VacancyUpdate(BaseModel):
    company_id: uuid.UUID | None = None
    employer_name: str | None = Field(default=None, min_length=1, max_length=255)
    position: str | None = Field(default=None, min_length=1, max_length=200)
    country_code: Country | None = None
    vessel_type: str | None = Field(default=None, max_length=100)
    salary_min: Decimal | None = Field(default=None, ge=0)
    salary_max: Decimal | None = Field(default=None, ge=0)
    currency: str | None = Field(default=None, pattern=r"^[A-Z]{3}$")
    salary_period: PayPeriod | None = None
    contract_duration: str | None = Field(default=None, max_length=100)
    rotation: str | None = Field(default=None, max_length=100)
    requirements: str | None = Field(default=None, max_length=10000)
    application_deadline: date | None = None
    status: Literal["expired"] | None = None  # 'active' only via /verify


class VacancyOut(VacancyBase):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    source_url: str
    status: VacancyStatus
    discovered_at: datetime
    last_verified_at: datetime | None
    created_at: datetime


CompanyDetail.model_rebuild()
