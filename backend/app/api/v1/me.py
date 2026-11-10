from fastapi import APIRouter, Request, Response, status
from sqlalchemy import delete, select
from sqlalchemy.orm import selectinload

from app.api.deps import CurrentUser, DbDep, audit
from app.models import CandidateProfile, User
from app.schemas.profile import MeOut, MeUpdate, ProfileOut

router = APIRouter(prefix="/me", tags=["account"])


@router.get("", response_model=MeOut)
def get_me(user: CurrentUser) -> User:
    return user


@router.patch("", response_model=MeOut)
def update_me(body: MeUpdate, request: Request, user: CurrentUser, db: DbDep) -> User:
    changes = body.model_dump(exclude_unset=True)
    for field, value in changes.items():
        setattr(user, field, value)
    audit(db, request, user, "account.updated", "user", user.id, fields=sorted(changes))
    db.commit()
    db.refresh(user)
    return user


@router.get("/export")
def export_my_data(user: CurrentUser, db: DbDep) -> dict:
    """GDPR data export. Covers the data domains implemented so far (account + profiles);
    later phases extend this export as new domains ship."""
    profiles = db.scalars(
        select(CandidateProfile)
        .where(CandidateProfile.user_id == user.id)
        .options(selectinload(CandidateProfile.experience))
    )
    return {
        "account": MeOut.model_validate(user).model_dump(mode="json"),
        "profiles": [ProfileOut.model_validate(p).model_dump(mode="json") for p in profiles],
        "included_domains": ["account", "profiles", "experience"],
    }


@router.delete("", status_code=status.HTTP_204_NO_CONTENT)
def delete_my_account(request: Request, user: CurrentUser, db: DbDep) -> Response:
    """Permanently deletes the user and every row they own (ON DELETE CASCADE).

    Audit entries are kept for security purposes with the user reference removed.
    The Supabase Auth identity must be deleted separately with the service-role key.
    """
    audit(db, request, user, "account.deleted", "user", user.id)
    db.flush()
    db.execute(delete(User).where(User.id == user.id))
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
