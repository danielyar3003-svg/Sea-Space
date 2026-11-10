from fastapi import APIRouter, HTTPException, status
from sqlalchemy import text

from app.api.deps import DbDep, SettingsDep

router = APIRouter(tags=["health"])


@router.get("/health")
def health() -> dict:
    """Liveness: the process is up."""
    return {"status": "ok"}


@router.get("/health/ready")
def ready(db: DbDep, settings: SettingsDep) -> dict:
    """Readiness: database reachable. Also reports which integrations are configured,
    so nothing pretends to be connected when it is not (no secret values are exposed)."""
    try:
        db.execute(text("SELECT 1"))
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, "Database unavailable") from exc
    return {
        "status": "ready",
        "environment": settings.app_env,
        "integrations": {
            "supabase_auth": settings.auth_configured,
            "token_encryption": settings.token_encryption_key is not None,
            "anthropic": settings.anthropic_api_key is not None,
            "gmail_oauth": bool(settings.google_client_id and settings.google_client_secret),
            "gmail_pubsub": settings.google_pubsub_topic is not None,
            "web_search": settings.brave_search_api_key is not None,
        },
    }
