"""Simple in-process sliding-window rate limiter.

Good enough for a single instance. With several API replicas, enforce limits at the
gateway / load balancer or move this to Redis (planned for Phase 8).
"""

import time
from collections import defaultdict, deque
from threading import Lock

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse


class RateLimitMiddleware(BaseHTTPMiddleware):
    def __init__(self, app, limit: int = 120, window_seconds: int = 60,  # noqa: ANN001
                 exempt_paths: tuple[str, ...] = ("/health",)) -> None:
        super().__init__(app)
        self.limit = limit
        self.window = window_seconds
        self.exempt = exempt_paths
        self._hits: dict[str, deque[float]] = defaultdict(deque)
        self._lock = Lock()

    async def dispatch(self, request: Request, call_next):  # noqa: ANN001, ANN201
        if request.url.path.startswith(self.exempt):
            return await call_next(request)
        key = request.client.host if request.client else "unknown"
        now = time.monotonic()
        with self._lock:
            hits = self._hits[key]
            while hits and hits[0] <= now - self.window:
                hits.popleft()
            if len(hits) >= self.limit:
                retry = int(self.window - (now - hits[0])) + 1
                return JSONResponse({"detail": "Too many requests"}, status_code=429,
                                    headers={"Retry-After": str(retry)})
            hits.append(now)
        return await call_next(request)
