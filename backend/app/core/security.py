"""Supabase access-token verification.

Two modes are supported:
* JWKS (recommended): asymmetric signing keys published at
  `{SUPABASE_URL}/auth/v1/.well-known/jwks.json`.
* Legacy shared secret (HS256) when `SUPABASE_JWT_SECRET` is set.
"""

from dataclasses import dataclass
from functools import lru_cache

import jwt
from jwt import PyJWKClient

from app.core.config import Settings


class AuthError(Exception):
    """Raised for any token problem. The message is safe to return to the client."""


@dataclass(frozen=True)
class TokenClaims:
    subject: str
    email: str | None
    role: str | None


@lru_cache
def _jwks_client(jwks_url: str) -> PyJWKClient:
    return PyJWKClient(jwks_url, cache_keys=True, lifespan=600, timeout=5)


def verify_access_token(token: str, settings: Settings) -> TokenClaims:
    if not settings.auth_configured:
        raise AuthError("Authentication is not configured on the server")

    issuer = f"{settings.supabase_url.rstrip('/')}/auth/v1" if settings.supabase_url else None
    options = {"require": ["exp", "sub"], "verify_iss": issuer is not None}
    try:
        if settings.supabase_jwt_secret is not None:
            payload = jwt.decode(
                token,
                settings.supabase_jwt_secret.get_secret_value(),
                algorithms=["HS256"],
                audience=settings.supabase_jwt_audience,
                issuer=issuer,
                options=options,
            )
        else:
            signing_key = _jwks_client(f"{issuer}/.well-known/jwks.json").get_signing_key_from_jwt(
                token
            )
            payload = jwt.decode(
                token,
                signing_key.key,
                algorithms=["RS256", "ES256"],
                audience=settings.supabase_jwt_audience,
                issuer=issuer,
                options=options,
            )
    except jwt.ExpiredSignatureError as exc:
        raise AuthError("Token expired") from exc
    except (jwt.PyJWTError, ValueError) as exc:
        raise AuthError("Invalid token") from exc

    return TokenClaims(subject=payload["sub"], email=payload.get("email"),
                       role=payload.get("role"))
