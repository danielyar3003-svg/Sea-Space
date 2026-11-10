import uuid
from datetime import UTC, datetime

from fastapi import APIRouter, HTTPException, Request, Response, status
from sqlalchemy import select, update
from sqlalchemy.orm import Session, selectinload

from app.api.deps import CurrentUser, DbDep, audit
from app.models import CandidateExperience, CandidateProfile, User
from app.schemas.profile import (
    ExperienceIn,
    ExperienceOut,
    ProfileCreate,
    ProfileOut,
    ProfileUpdate,
)

router = APIRouter(prefix="/profiles", tags=["profiles"])


def _query(user: User):
    return (
        select(CandidateProfile)
        .where(CandidateProfile.user_id == user.id, CandidateProfile.deleted_at.is_(None))
        .options(selectinload(CandidateProfile.experience))
    )


def _get_profile(db: Session, user: User, profile_id: uuid.UUID) -> CandidateProfile:
    profile = db.scalar(_query(user).where(CandidateProfile.id == profile_id))
    if profile is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Profile not found")
    return profile


def _clear_primary(db: Session, user: User) -> None:
    db.execute(
        update(CandidateProfile)
        .where(CandidateProfile.user_id == user.id, CandidateProfile.is_primary.is_(True))
        .values(is_primary=False)
    )
    db.flush()


@router.get("", response_model=list[ProfileOut])
def list_profiles(user: CurrentUser, db: DbDep) -> list[CandidateProfile]:
    return list(db.scalars(_query(user).order_by(CandidateProfile.is_primary.desc(),
                                                 CandidateProfile.created_at)))


@router.post("", response_model=ProfileOut, status_code=status.HTTP_201_CREATED)
def create_profile(body: ProfileCreate, request: Request, user: CurrentUser,
                   db: DbDep) -> CandidateProfile:
    has_profiles = db.scalar(_query(user).limit(1)) is not None
    make_primary = body.is_primary or not has_profiles
    if make_primary:
        _clear_primary(db, user)
    profile = CandidateProfile(user_id=user.id, **body.model_dump(exclude={"is_primary"}),
                               is_primary=make_primary)
    db.add(profile)
    db.flush()
    audit(db, request, user, "profile.created", "candidate_profile", profile.id)
    db.commit()
    return _get_profile(db, user, profile.id)


@router.get("/primary", response_model=ProfileOut)
def get_primary_profile(user: CurrentUser, db: DbDep) -> CandidateProfile:
    profile = db.scalar(_query(user).where(CandidateProfile.is_primary.is_(True)))
    if profile is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "No profile yet")
    return profile


@router.get("/{profile_id}", response_model=ProfileOut)
def get_profile(profile_id: uuid.UUID, user: CurrentUser, db: DbDep) -> CandidateProfile:
    return _get_profile(db, user, profile_id)


@router.patch("/{profile_id}", response_model=ProfileOut)
def update_profile(profile_id: uuid.UUID, body: ProfileUpdate, request: Request,
                   user: CurrentUser, db: DbDep) -> CandidateProfile:
    profile = _get_profile(db, user, profile_id)
    changes = body.model_dump(exclude_unset=True)
    if changes.get("is_primary") is True and not profile.is_primary:
        _clear_primary(db, user)
    elif changes.get("is_primary") is False and profile.is_primary:
        raise HTTPException(status.HTTP_409_CONFLICT,
                            "Mark another profile as primary instead")
    for field, value in changes.items():
        setattr(profile, field, value)
    audit(db, request, user, "profile.updated", "candidate_profile", profile.id,
          fields=sorted(changes))
    db.commit()
    db.refresh(profile)
    return _get_profile(db, user, profile_id)


@router.delete("/{profile_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_profile(profile_id: uuid.UUID, request: Request, user: CurrentUser,
                   db: DbDep) -> Response:
    profile = _get_profile(db, user, profile_id)
    profile.deleted_at = datetime.now(UTC)
    was_primary = profile.is_primary
    profile.is_primary = False
    db.flush()
    if was_primary:
        successor = db.scalar(_query(user).order_by(CandidateProfile.created_at).limit(1))
        if successor is not None:
            successor.is_primary = True
    audit(db, request, user, "profile.deleted", "candidate_profile", profile.id)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


# --- Experience --------------------------------------------------------------------------


def _get_experience(db: Session, user: User, profile_id: uuid.UUID,
                    experience_id: uuid.UUID) -> CandidateExperience:
    item = db.scalar(select(CandidateExperience).where(
        CandidateExperience.id == experience_id,
        CandidateExperience.profile_id == profile_id,
        CandidateExperience.user_id == user.id,
    ))
    if item is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Experience entry not found")
    return item


@router.post("/{profile_id}/experience", response_model=ExperienceOut,
             status_code=status.HTTP_201_CREATED)
def add_experience(profile_id: uuid.UUID, body: ExperienceIn, request: Request,
                   user: CurrentUser, db: DbDep) -> CandidateExperience:
    _get_profile(db, user, profile_id)
    item = CandidateExperience(user_id=user.id, profile_id=profile_id, **body.model_dump())
    db.add(item)
    db.flush()
    audit(db, request, user, "experience.created", "candidate_experience", item.id)
    db.commit()
    return item


@router.put("/{profile_id}/experience/{experience_id}", response_model=ExperienceOut)
def replace_experience(profile_id: uuid.UUID, experience_id: uuid.UUID, body: ExperienceIn,
                       request: Request, user: CurrentUser, db: DbDep) -> CandidateExperience:
    item = _get_experience(db, user, profile_id, experience_id)
    for field, value in body.model_dump().items():
        setattr(item, field, value)
    audit(db, request, user, "experience.updated", "candidate_experience", item.id)
    db.commit()
    db.refresh(item)
    return item


@router.delete("/{profile_id}/experience/{experience_id}",
               status_code=status.HTTP_204_NO_CONTENT)
def delete_experience(profile_id: uuid.UUID, experience_id: uuid.UUID, request: Request,
                      user: CurrentUser, db: DbDep) -> Response:
    item = _get_experience(db, user, profile_id, experience_id)
    db.delete(item)
    audit(db, request, user, "experience.deleted", "candidate_experience", experience_id)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
