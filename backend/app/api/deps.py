from datetime import UTC, datetime
from typing import Annotated

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.core.security import AuthError, verify_access_token
from app.db.session import get_db
from app.models import AuditLog, User

bearer = HTTPBearer(auto_error=False)

SettingsDep = Annotated[Settings, Depends(get_settings)]
DbDep = Annotated[Session, Depends(get_db)]


def get_current_user(
    request: Request,
    db: DbDep,
    settings: SettingsDep,
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(bearer)],
) -> User:
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Missing bearer token",
                            headers={"WWW-Authenticate": "Bearer"})
    try:
        claims = verify_access_token(credentials.credentials, settings)
    except AuthError as exc:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, str(exc),
                            headers={"WWW-Authenticate": "Bearer"}) from exc

    user = db.scalar(select(User).where(User.auth_subject == claims.subject))
    if user is None:
        user = User(auth_subject=claims.subject, email=claims.email)
        db.add(user)
        db.flush()
        db.add(AuditLog(user_id=user.id, action="user.provisioned", entity_type="user",
                        entity_id=str(user.id), ip_address=_client_ip(request)))
    elif user.deleted_at is not None:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Account has been deleted")
    else:
        if claims.email and user.email != claims.email:
            user.email = claims.email
    user.last_seen_at = datetime.now(UTC)
    db.commit()

    # From now on every transaction in this session runs with the RLS context set.
    db.info["user_id"] = user.id
    return user


CurrentUser = Annotated[User, Depends(get_current_user)]


def _client_ip(request: Request) -> str | None:
    return request.client.host if request.client else None


def audit(db: Session, request: Request, user: User, action: str, entity_type: str | None = None,
          entity_id: object = None, **details: object) -> None:
    db.add(AuditLog(
        user_id=user.id,
        action=action,
        entity_type=entity_type,
        entity_id=str(entity_id) if entity_id is not None else None,
        ip_address=_client_ip(request),
        user_agent=request.headers.get("user-agent"),
        details=details,
    ))
