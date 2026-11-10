"""Environment-based configuration.

Every secret is read from the environment (or a local, git-ignored `.env`).
Nothing secret has a default value.
"""

from functools import lru_cache
from typing import Literal

from pydantic import Field, SecretStr, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_env: Literal["development", "test", "staging", "production"] = "development"
    app_name: str = "SEA SPACE API"
    api_v1_prefix: str = "/api/v1"
    log_level: str = "INFO"

    database_url: str = Field(
        default="postgresql+psycopg://seaspace:seaspace@localhost:5432/seaspace",
        description="SQLAlchemy URL. The production role must NOT be a superuser (RLS).",
    )
    db_pool_size: int = 5

    # CORS origins for the Flutter web build / admin panel (comma separated).
    cors_origins: str = "http://localhost:3000,http://localhost:8080"

    # --- Supabase Auth -------------------------------------------------------
    # Tokens are verified either with the project's JWKS (asymmetric signing keys,
    # recommended) or with the legacy HS256 JWT secret, if it is set.
    supabase_url: str | None = None
    supabase_jwt_secret: SecretStr | None = None
    supabase_jwt_audience: str = "authenticated"

    # --- Field-level encryption (OAuth tokens, sensitive metadata) -----------
    # 32-byte urlsafe-base64 Fernet key. Generate with:
    #   python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
    token_encryption_key: SecretStr | None = None

    # --- Integrations configured in later phases ----------------------------
    anthropic_api_key: SecretStr | None = None
    anthropic_model: str = "claude-opus-5-5"
    google_client_id: str | None = None
    google_client_secret: SecretStr | None = None
    google_pubsub_topic: str | None = None

    # --- Discovery engine ----------------------------------------------------------------
    brave_search_api_key: SecretStr | None = None
    discovery_min_interval_seconds: float = 1.0
    # Only for tests/local fixtures. Never enable in production (SSRF protection).
    discovery_allow_private_hosts: bool = False

    @property
    def cors_origin_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    @property
    def auth_configured(self) -> bool:
        return bool(self.supabase_jwt_secret or self.supabase_url)

    @model_validator(mode="after")
    def _production_guards(self) -> "Settings":
        if self.app_env == "production":
            if not self.auth_configured:
                raise ValueError("Supabase auth must be configured in production")
            if self.discovery_allow_private_hosts:
                raise ValueError("DISCOVERY_ALLOW_PRIVATE_HOSTS must be off in production")
            if "*" in self.cors_origin_list:
                raise ValueError("Wildcard CORS is not allowed in production")
        return self


@lru_cache
def get_settings() -> Settings:
    return Settings()
