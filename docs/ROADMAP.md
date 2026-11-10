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

## Phase 4 — CRM ✅ (with limitations)
| Item | Status |
|---|---|
| Applications with 14 pipeline statuses, status history with notes, sent/reply timestamps | ✅ |
| Kanban board (stages with applications, pipeline order) | ✅ |
| Follow-up reminders: per application or company, open / overdue / done, "remind in N days" on status change | ✅ |
| Company timeline built from records (notes, contacts, sources, vacancies, applications, follow-ups) | ✅ |
| Pipeline statistics: sent, replies, reply rate, median days to reply, interviews, offers | ✅ |
| Contact must belong to the application's company; per-user isolation incl. RLS | ✅ 6 CRM tests + RLS end-to-end |
| Push / e-mail reminders when a follow-up is due | ⏳ needs notifications (Phase 7); overdue items are shown in the app |
| Attachments on applications | ⏳ needs the document vault (Phase 7) |

## Interface languages ✅
English, Ukrainian and Russian (Flutter gen-l10n, ICU plurals). The choice is stored on the
device and in the account (`users.locale`), and can be changed on the login screen or in
Settings. Server validation messages are still English; network/timeout/server errors are
translated in the app. Source strings: `app/tool/strings.py` → `lib/l10n/*.arb`.

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
