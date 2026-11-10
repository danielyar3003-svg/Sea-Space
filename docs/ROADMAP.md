# SEA SPACE — Roadmap & status

Status legend: ✅ done and tested · 🟡 partial · ⏳ not started.

## Phase 1 — Architecture ✅
Architecture, directory structure, schema, API contracts, auth and security model, navigation,
services/costs, risks — see `ARCHITECTURE.md`, `API.md`, `SERVICES.md`, `SECURITY.md`.

## Phase 2 — Foundation ✅ (with limitations)
| Item | Status |
|---|---|
| FastAPI backend, env config, error handling, security headers, rate limiting | ✅ |
| PostgreSQL schema (31 tables), Alembic migration with RLS + vessel-type reference data | ✅ upgrade/downgrade/`alembic check` verified |
| Supabase JWT verification (JWKS or HS256), user provisioning, audit log | ✅ tested with HS256 test tokens; JWKS path not yet tested against a live project |
| Profiles + sea-service API, dashboard API, account export/deletion | ✅ 18 backend tests |
| Flutter app: theme/design system, responsive shell, GoRouter, Riverpod | ✅ |
| Login / sign-up / password reset (Supabase), setup screen when unconfigured | 🟡 widget-tested with a fake auth service; needs a real Supabase project to test end to end |
| Home dashboard, Profile (create from suggested profile, edit, sea service), Settings | ✅ 10 Flutter tests |
| Dockerfile, docker-compose, CI workflow | 🟡 written, not yet run (Docker Hub blocked in the dev sandbox; CI runs on first push) |

## Phase 3 — Company intelligence ✅ (with limitations)
| Item | Status |
|---|---|
| Companies: CRUD, filters, name normalisation, duplicate detection (name / website domain) with explicit override, merge, notes, websites, sources | ✅ |
| Verification only via `/verify` with the source the user checked; DB enforces "verified needs source + date" | ✅ |
| HR contacts: people vs recruitment inboxes, e-mail origin (published / entered / guessed), domain-consistency flag, filters | ✅ |
| Guessed (inferred) e-mails can never be verified — API check + DB constraint (migration 0002) | ✅ |
| Fleet: vessel types, IMO checksum, separate owner and operator links, crewing employer = unknown by default | ✅ |
| Vacancies: unverified until checked, automatic expiry after deadline, salary validation | ✅ |
| Discovery: SSRF-safe fetcher, robots.txt, throttling; website research → sourced findings → explicit import | ✅ tested against a local fixture site |
| Research targets from the brief (names only) | ✅ |
| Web search (Brave Search API) | 🟡 client written; untested against the live API until a key is configured |
| Flutter: Companies list/detail/form, duplicate dialog, research sheet, Discover (employers, vacancies, search), HR Contacts, Fleet, duplicates review | ✅ 16 Flutter tests incl. a contract test on real API responses |

Limitations: website research reads at most 4 pages per site and does not render JavaScript-only
sites; public registries (fleet/business) need per-source adapters (not yet written); the
duplicate check compares within one user's workspace only.

## Phase 4 — CRM ⏳
Kanban pipeline (14 statuses), status history, company timeline, follow-ups and reminders.

## Phase 5 — Gmail ⏳
OAuth (minimal scopes), encrypted tokens, history sync, Watch + Pub/Sub with renewal,
reconciliation job, thread/company linking with confirmation, approval-gated sending.

## Phase 6 — AI ⏳
Claude service (server-side, structured JSON outputs, tool use), drafts, translation EN/UK/RU,
reply analysis, CV adaptation, company reports with sources and verified-vs-assumed split.

## Phase 7 — Advanced ⏳
Salary database with period normalisation, document vault (Supabase Storage, encryption,
expiry reminders), scam detector, recruitment map, interview trainer, analytics, push notifications.

## Phase 8 — Release ⏳
Security audit, performance, iOS/Android signing and store builds, web admin deployment,
role-based admin screens, Redis rate limiting, monitoring, full documentation.
