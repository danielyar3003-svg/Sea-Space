# SEA SPACE

**Maritime Career Intelligence Platform:** an app that helps seafarers find employers, recruitment contacts and vacancies, apply to them directly, and run their whole job search in one place. That includes companies that are not currently advertising vacancies.

| Part | Stack |
|---|---|
| `app/` | Flutter (iOS, Android, Web / admin) · Riverpod · GoRouter · Material 3 dark design system |
| `backend/` | Python 3.13 · FastAPI · SQLAlchemy 2 · Alembic · PostgreSQL 16 (row-level security) · Supabase Auth |

**Status:** Phases 1–2 are finished (architecture and foundation). See [docs/ROADMAP.md](docs/ROADMAP.md) for what works today and what is still to come.

Documentation: [Architecture](docs/ARCHITECTURE.md) · [API](docs/API.md) · [Services, credentials & costs](docs/SERVICES.md) · [Security](docs/SECURITY.md) · [Roadmap](docs/ROADMAP.md)

---

## 1. Prerequisites

* Python 3.13 and [uv](https://docs.astral.sh/uv/)
* PostgreSQL 16 (local install, or the `db` service in `docker-compose.yml`)
* Flutter 3.47 (stable)
* A [Supabase](https://supabase.com) project, used for sign-in

## 2. Backend

```bash
cd backend
cp .env.example .env            # fill in SUPABASE_URL (and optionally SUPABASE_JWT_SECRET)
uv sync                         # install dependencies
uv run alembic upgrade head     # create schema + row-level security
uv run uvicorn app.main:app --reload
```

* API: http://localhost:8000. Interactive docs: http://localhost:8000/docs
* `GET /health/ready` shows which integrations are configured.

Local database with Docker instead of a local PostgreSQL install:

```bash
docker compose up -d db
```

**Production note:** connect the API with a database role that is **not** a superuser and does not have `BYPASSRLS`. Otherwise row-level security is bypassed.

### Tests

```bash
cd backend
uv run ruff check .
uv run pytest            # needs PostgreSQL; uses TEST_DATABASE_URL (default …/seaspace_test)
```

## 3. Flutter app

```bash
cd app
flutter pub get
flutter run \
  --dart-define=API_BASE_URL=http://localhost:8000 \
  --dart-define=SUPABASE_URL=https://<project>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable key>
```

* Without the Supabase values, the app shows a "not configured" screen and does not try to connect to anything.
* Web / admin build:

  ```bash
  flutter build web --release --no-web-resources-cdn
  ```

  This bundles CanvasKit with the build, so the app does not load it from Google's CDN.
* Android: `flutter build apk`. iOS: `flutter build ipa`. The iOS build requires macOS with Xcode. Signing setup is part of Phase 8.

Tests: `flutter analyze && flutter test`

## 4. Supabase setup (sign-in)

1. Create a project.
2. Go to **Project Settings → API** and copy the project URL into `SUPABASE_URL` (both the backend and the app).
3. Copy the publishable key into the app's `SUPABASE_PUBLISHABLE_KEY`.
4. To verify tokens, the backend uses the project's JWKS by default. If your project still signs tokens with the legacy JWT secret, set it as `SUPABASE_JWT_SECRET` in `backend/.env`.
5. Under **Authentication → URL configuration**, add your app or web URLs.

The Google OAuth, Gmail and Claude guides are written as those phases are built. [docs/SERVICES.md](docs/SERVICES.md) lists every credential, which phase needs it, and the expected costs.

## 5. Rules this codebase follows

* No fake data in production. Dashboard numbers are live database counts. Unfinished modules show the phase they are planned for instead of sample data.
* Nothing is stored as *verified* unless it has a source URL and a verification date. The database enforces this.
* Candidate facts (certificates, dates, sea service) are never invented.
* E-mails are sent only after the user explicitly approves each one. There is no bulk sending.
* Secrets are never committed. They live in environment variables or a secret manager.
