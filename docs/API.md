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

## Implemented (Phase 3)

| Method | Path | Description |
|---|---|---|
| GET | `/companies` | Filters: `q`, `country`, `hiring_status`, `industry`, `verified`, `limit`, `offset` |
| POST | `/companies` | Create. `409` with `detail.candidates` for likely duplicates; resend with `allow_duplicate: true` when `can_override` |
| GET | `/companies/duplicates` | Pairs of likely duplicates (same name, similar name, same website domain) |
| GET/PATCH/DELETE | `/companies/{id}` | Detail (websites, sources, notes, vessel links) / partial update / soft delete |
| POST | `/companies/{id}/verify` | `{source_url, confidence?}` — the only way to mark a company verified |
| POST | `/companies/{id}/merge` | `{into_id}` — moves all related records to the target |
| POST/DELETE | `/companies/{id}/websites[/{wid}]`, `/sources[/{sid}]`, `/notes[/{nid}]` (+ PATCH note) | |
| GET | `/contacts` | `filter=all\|verified\|unverified\|generic\|people\|inferred`, `q`, `company_id` |
| POST | `/companies/{id}/contacts` | Create (e-mail origin stored; `source_url` optional) |
| PATCH/DELETE | `/contacts/{id}` | Changing a verified e-mail removes the verification |
| POST | `/contacts/{id}/verify` | Refused (`422`) for guessed e-mails |
| GET | `/vessel-types` | Shared reference data |
| GET/POST | `/vessels` | Filters: `q`, `company_id`, `vessel_type_id`; IMO checksum + uniqueness |
| GET/PATCH/DELETE | `/vessels/{id}`; POST `/vessels/{id}/verify` | |
| POST/DELETE | `/vessels/{id}/links[/{lid}]` | `{company_id, role: owner\|operator, is_crewing_employer?}` |
| GET/POST | `/vacancies` | Filters: `status`, `q`, `country`, `company_id`; new = `unverified` |
| PATCH/DELETE | `/vacancies/{id}`; POST `/vacancies/{id}/verify` | Verify = user checked the posting is open |
| POST | `/discovery/website` | `{url, company_id?}` → findings with source URL + excerpt; nothing saved |
| POST | `/discovery/import` | Save one reviewed finding (email / careers_page / contact_page / speculative_policy) |
| POST | `/discovery/search` | Brave Search; `503` when not configured |
| GET/POST | `/discovery/targets`, `/discovery/targets/import` | Research targets from the brief (names only) |

## Planned contracts (Phases 4–7)

| Phase | Resource | Endpoints |
|---|---|---|
| 4 | CRM | `GET/POST /applications`, `PATCH /applications/{id}` (status change writes history), `GET /applications/board`, `GET /companies/{id}/timeline`, `GET/POST/PATCH /follow-ups` |
| 5 | Gmail | `GET /mail/oauth/start`, `GET /mail/oauth/callback`, `GET /mail/accounts`, `DELETE /mail/accounts/{id}`, `GET /mail/threads?folder=`, `GET /mail/threads/{id}`, `POST /mail/threads/{id}/link` (confirm/reject company link), `POST /mail/drafts`, `POST /mail/drafts/{id}/send` (requires `confirm: true` + full preview hash), `POST /mail/pubsub` (Google push, verified JWT) |
| 6 | AI | `POST /ai/drafts` (cover letter / email / reply / follow-up), `POST /ai/translate`, `POST /ai/analyze-reply`, `POST /ai/cv-adapt`, `POST /ai/company-report`, `GET/POST /ai/conversations` |
| 7 | Other | `/documents` (signed upload/download URLs), `/salaries/offers`, `/salaries/benchmarks`, `/safety/check`, `/interview/sessions`, `/map/features`, `/analytics/summary`, `/notifications/preferences` |
