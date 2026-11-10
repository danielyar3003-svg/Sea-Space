"""Import every model so Alembic sees the complete metadata."""

from app.db.base import Base
from app.models.candidate import (
    CandidateCertificate,
    CandidateDocument,
    CandidateExperience,
    CandidateProfile,
)
from app.models.company import (
    Company,
    CompanyContact,
    CompanyIndustry,
    CompanyNote,
    CompanySource,
    CompanyWebsite,
    ContactSource,
    Vacancy,
)
from app.models.crm import ApplicationStatusHistory, FollowUpTask, JobApplication
from app.models.email import EmailAccount, EmailAttachment, EmailMessage, EmailThread
from app.models.fleet import Vessel, VesselOperator, VesselOwner, VesselType
from app.models.misc import (
    AIConversation,
    AIGeneratedDraft,
    SalaryBenchmark,
    SalaryOffer,
    SearchHistory,
)
from app.models.user import AuditLog, NotificationPreferences, User

# Tables with a `user_id` column that are isolated per user by row-level security.
USER_OWNED_TABLES: tuple[str, ...] = tuple(
    sorted(
        t.name
        for t in Base.metadata.sorted_tables
        if "user_id" in t.c and t.name != "audit_logs"
    )
)

__all__ = [
    "AIConversation", "AIGeneratedDraft", "ApplicationStatusHistory", "AuditLog", "Base",
    "CandidateCertificate", "CandidateDocument", "CandidateExperience", "CandidateProfile",
    "Company", "CompanyContact", "CompanyIndustry", "CompanyNote", "CompanySource",
    "CompanyWebsite", "ContactSource", "EmailAccount", "EmailAttachment", "EmailMessage",
    "EmailThread", "FollowUpTask", "JobApplication", "NotificationPreferences",
    "SalaryBenchmark", "SalaryOffer", "SearchHistory", "USER_OWNED_TABLES", "User", "Vacancy",
    "Vessel", "VesselOperator", "VesselOwner", "VesselType",
]
