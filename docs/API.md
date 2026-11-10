# SEA SPACE — API

Base path: `/api/v1`. All endpoints except `/health*` require
`Authorization: Bearer <Supabase access token>`. Interactive docs (non-production):
`http://localhost:8000/docs`.

Errors are JSON `{"detail": …}`: `401` bad/missing token, `403` deleted account,
`404` not found **or not yours** (no existence leaks), `409` conflict, `422` validation,
`429` rate limited (`Retry-After`), `500` generic.

## Implemented (Phase 2)

| Method | Path | Description |
|---|---|---|
| GET | `/health` | Liveness |
| GET | `/health/ready` | DB check + which integrations are configured (booleans only) |
| GET | `/me` | Current account (provisioned on first call) |
| PATCH | `/me` | `display_name`, `locale` (`en/uk/ru`), `consent_analytics` |
| GET | `/me/export` | GDPR export of implemented domains (account, profiles, experience) |
| DELETE | `/me` | Permanently delete account data (cascade) |
| GET | `/profiles` | List profiles (primary first) |
| POST | `/profiles` | Create; the first profile becomes primary |
| GET | `/profiles/primary` | Primary profile (`404` if none yet) |
| GET | `/profiles/{id}` | One profile with sea-service entries |
| PATCH | `/profiles/{id}` | Partial update; `is_primary: true` moves primary flag |
| DELETE | `/profiles/{id}` | Soft delete; another profile is promoted if needed |
| POST | `/profiles/{id}/experience` | Add sea-service entry (dates optional) |
| PUT | `/profiles/{id}/experience/{eid}` | Replace entry |
| DELETE | `/profiles/{id}/experience/{eid}` | Delete entry |
| GET | `/dashboard/summary` | Live counts + upcoming follow-ups, new companies, recent activity |

## Planned contracts (Phases 3–7)

| Phase | Resource | Endpoints |
|---|---|---|
| 3 | Companies | `GET/POST /companies`, `GET/PATCH/DELETE /companies/{id}`, `POST /companies/{id}/merge`, `GET /companies/duplicates`, `/companies/{id}/sources`, `/companies/{id}/websites`, `/companies/{id}/notes` |
| 3 | Contacts | `GET/POST /companies/{id}/contacts`, `PATCH/DELETE /contacts/{id}`, `GET /contacts?status=verified\|unverified\|generic` |
| 3 | Fleet | `GET/POST /vessels`, `PATCH/DELETE /vessels/{id}`, `POST /vessels/{id}/owners`, `POST /vessels/{id}/operators`, `GET /vessel-types` |
| 3 | Discovery | `POST /discovery/runs` (source + query, async), `GET /discovery/runs/{id}` (results with source URLs; user imports items explicitly) |
| 3 | Vacancies | `GET/POST /vacancies`, `PATCH /vacancies/{id}`, `POST /vacancies/{id}/verify`, saved searches via `/searches` |
| 4 | CRM | `GET/POST /applications`, `PATCH /applications/{id}` (status change writes history), `GET /applications/board`, `GET /companies/{id}/timeline`, `GET/POST/PATCH /follow-ups` |
| 5 | Gmail | `GET /mail/oauth/start`, `GET /mail/oauth/callback`, `GET /mail/accounts`, `DELETE /mail/accounts/{id}`, `GET /mail/threads?folder=`, `GET /mail/threads/{id}`, `POST /mail/threads/{id}/link` (confirm/reject company link), `POST /mail/drafts`, `POST /mail/drafts/{id}/send` (requires `confirm: true` + full preview hash), `POST /mail/pubsub` (Google push, verified JWT) |
| 6 | AI | `POST /ai/drafts` (cover letter / email / reply / follow-up), `POST /ai/translate`, `POST /ai/analyze-reply`, `POST /ai/cv-adapt`, `POST /ai/company-report`, `GET/POST /ai/conversations` |
| 7 | Other | `/documents` (signed upload/download URLs), `/salaries/offers`, `/salaries/benchmarks`, `/safety/check`, `/interview/sessions`, `/map/features`, `/analytics/summary`, `/notifications/preferences` |
