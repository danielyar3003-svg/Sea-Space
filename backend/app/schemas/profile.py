import uuid
from datetime import date, datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, EmailStr, Field, model_validator

from app.models.enums import EnglishLevel

ShortText = Field(default=None, max_length=200)


class ExperienceIn(BaseModel):
    vessel_name: str | None = Field(default=None, max_length=200)
    vessel_type: str | None = Field(default=None, max_length=100)
    employer_name: str | None = Field(default=None, max_length=200)
    position: str | None = Field(default=None, max_length=120)
    duties: list[str] = Field(default_factory=list, max_length=50)
    start_date: date | None = None
    end_date: date | None = None
    notes: str | None = Field(default=None, max_length=5000)
    sort_order: int = 0

    @model_validator(mode="after")
    def _dates(self) -> "ExperienceIn":
        if self.start_date and self.end_date and self.end_date < self.start_date:
            raise ValueError("end_date must not be before start_date")
        return self


class ExperienceOut(ExperienceIn):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    profile_id: uuid.UUID
    created_at: datetime
    updated_at: datetime


class ProfileBase(BaseModel):
    label: str = Field(default="Main profile", min_length=1, max_length=120)
    full_name: str | None = ShortText
    nationality: str | None = Field(default=None, max_length=100)
    english_level: EnglishLevel | None = None
    years_of_experience: Decimal | None = Field(default=None, ge=0, le=70, decimal_places=1)
    experience_is_approximate: bool = True
    target_positions: list[str] = Field(default_factory=list, max_length=30)
    experience_areas: list[str] = Field(default_factory=list, max_length=50)
    languages: list[str] = Field(default_factory=list, max_length=20)
    summary: str | None = Field(default=None, max_length=5000)
    phone: str | None = Field(default=None, max_length=50)
    contact_email: EmailStr | None = None
    home_port: str | None = ShortText


class ProfileCreate(ProfileBase):
    is_primary: bool = False


class ProfileUpdate(BaseModel):
    """Partial update: only fields present in the request are changed."""

    label: str | None = Field(default=None, min_length=1, max_length=120)
    full_name: str | None = ShortText
    nationality: str | None = Field(default=None, max_length=100)
    english_level: EnglishLevel | None = None
    years_of_experience: Decimal | None = Field(default=None, ge=0, le=70, decimal_places=1)
    experience_is_approximate: bool | None = None
    target_positions: list[str] | None = Field(default=None, max_length=30)
    experience_areas: list[str] | None = Field(default=None, max_length=50)
    languages: list[str] | None = Field(default=None, max_length=20)
    summary: str | None = Field(default=None, max_length=5000)
    phone: str | None = Field(default=None, max_length=50)
    contact_email: EmailStr | None = None
    home_port: str | None = ShortText
    is_primary: bool | None = None


class ProfileOut(ProfileBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    is_primary: bool
    experience: list[ExperienceOut]
    created_at: datetime
    updated_at: datetime


class MeOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    email: str | None
    display_name: str | None
    locale: str
    consent_analytics: bool
    created_at: datetime


class MeUpdate(BaseModel):
    display_name: str | None = Field(default=None, max_length=200)
    locale: str | None = Field(default=None, pattern=r"^(en|uk|ru)$")
    consent_analytics: bool | None = None
