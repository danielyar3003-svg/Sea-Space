import logging

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy.exc import IntegrityError

from app.api.v1 import (
    companies,
    contacts,
    dashboard,
    discovery,
    fleet,
    health,
    me,
    profiles,
    vacancies,
)
from app.core.config import get_settings
from app.core.rate_limit import RateLimitMiddleware

logger = logging.getLogger("seaspace")


def create_app() -> FastAPI:
    settings = get_settings()
    logging.basicConfig(level=settings.log_level)

    app = FastAPI(
        title=settings.app_name,
        version="0.1.0",
        description="SEA SPACE — Maritime Career Intelligence Platform API",
        docs_url=None if settings.app_env == "production" else "/docs",
        redoc_url=None if settings.app_env == "production" else "/redoc",
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origin_list,
        allow_credentials=False,
        allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE"],
        allow_headers=["Authorization", "Content-Type"],
    )
    if settings.app_env != "test":
        app.add_middleware(RateLimitMiddleware)

    @app.middleware("http")
    async def security_headers(request: Request, call_next):  # noqa: ANN001, ANN202
        response = await call_next(request)
        response.headers.setdefault("X-Content-Type-Options", "nosniff")
        response.headers.setdefault("X-Frame-Options", "DENY")
        response.headers.setdefault("Referrer-Policy", "no-referrer")
        if settings.app_env == "production":
            response.headers.setdefault("Strict-Transport-Security",
                                        "max-age=63072000; includeSubDomains")
        return response

    @app.exception_handler(IntegrityError)
    async def integrity(request: Request, exc: IntegrityError) -> JSONResponse:
        # Database constraints are the last line of defence; report them without internals.
        constraint = getattr(getattr(exc.orig, "diag", None), "constraint_name", "") or ""
        if "verified_requires_source" in constraint:
            return JSONResponse({"detail": "Only data with a source URL and verification date "
                                           "can be marked verified"}, status_code=422)
        if constraint.startswith("ck_"):
            return JSONResponse({"detail": "A value is not allowed for this field"},
                                status_code=422)
        return JSONResponse({"detail": "This conflicts with data you already saved"},
                            status_code=409)

    @app.exception_handler(Exception)
    async def unhandled(request: Request, exc: Exception) -> JSONResponse:
        # Never leak stack traces or internal details to clients.
        logger.exception("Unhandled error on %s %s", request.method, request.url.path)
        return JSONResponse({"detail": "Internal server error"}, status_code=500)

    app.include_router(health.router)
    for router in (me.router, profiles.router, dashboard.router, companies.router,
                   contacts.router, fleet.router, vacancies.router, discovery.router):
        app.include_router(router, prefix=settings.api_v1_prefix)
    return app


app = create_app()
