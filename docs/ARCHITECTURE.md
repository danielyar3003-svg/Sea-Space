# SEA SPACE — Architecture (Phase 1)

SEA SPACE is a personal Maritime Career Intelligence Platform: it helps a seafarer find
employers (including those with no advertised vacancies), identify recruitment contacts,
send personalised applications **only after explicit approval**, and track the whole search.

## 1. System overview

```
┌──────────────────────────┐        HTTPS + Supabase JWT        ┌────────────────────────────┐
│ Flutter app              │ ─────────────────────────────────▶ │ FastAPI backend (Python)   │
│  iOS · Android · Web     │                                    │  /api/v1/*                 │
│  Riverpod · GoRouter     │ ◀── Supabase Auth (sign-in) ──┐    │  SQLAlchemy · Pydantic     │
└──────────────────────────┘                               │    └──────┬───────────┬─────────┘
                                                           │           │           │
                                              ┌────────────┴───┐  ┌────▼────┐  ┌───▼──────────────────┐
                                              │ Supabase Auth  │  │Postgres │  │ External services    │
                                              │ + Storage      │  │ (RLS)   │  │ Claude API · Gmail · │
                                              └────────────────┘  └─────────┘  │ Pub/Sub · FCM/APNs · │
                                                                               │ Maps · PostHog       │
                                                                               └──────────────────────┘
```

* **The client never holds server secrets.** It knows only the API URL, the Supabase URL and
  the Supabase *publishable* key. Claude, Google and Firebase server credentials live only on
  the backend.
* **One backend, modular services.** Each integration sits behind its own service module
  (`app/services/…`) so a provider can be swapped (e.g. Mapbox ↔ Google Maps) without
  touching API routes or the database.
* **Web admin panel** = the same Flutter codebase built for web, with a responsive layout
  (navigation rail ≥ 840 px). Admin-only screens are added in Phase 8 behind a role check.

## 2. Repository layout

```
Sea-Space/
├── backend/                     FastAPI service
│   ├── app/
│   │   ├── api/deps.py          auth dependency, audit helper
│   │   ├── api/v1/              routers: health, me, profiles, dashboard (+ later phases)
│   │   ├── core/                config, JWT verification, encryption, rate limiting
│   │   ├── db/                  declarative base + mixins, session with RLS context
│   │   ├── models/              31 tables (see §3)
│   │   ├── schemas/             Pydantic request/response models
│   │   └── services/            integrations (Claude, Gmail, discovery…) — Phases 3–7
│   ├── alembic/                 migrations (0001_initial = full schema + RLS)
│   ├── tests/                   pytest against real PostgreSQL
│   ├── Dockerfile
│   └── .env.example
├── app/                         Flutter app (iOS / Android / Web)
│   ├── lib/core/                theme tokens, reusable widgets, API client, auth, providers
│   ├── lib/router/              GoRouter, responsive shell, feature registry
│   ├── lib/features/            auth, home, profile, settings, placeholders
│   └── test/                    widget + unit tests
├── docs/                        this documentation
├── docker-compose.yml           local Postgres + API
└── .github/workflows/ci.yml     lint, tests, migration check, web build
```

## 3. Database

PostgreSQL 16, managed with Alembic. Conventions used by every table:

| Convention | How |
|---|---|
| Primary keys | UUID, `gen_random_uuid()` |
| Timestamps | `created_at`, `updated_at` (timezone-aware) |
| Soft delete | `deleted_at` on user-facing entities (companies, contacts, vacancies, documents, applications…) |
| Ownership | `user_id → users.id ON DELETE CASCADE`, indexed |
| Isolation | Row-level security on all 28 user-owned tables (§5) |
| Provenance | `source_url`, `verification_status` (`verified / unverified / inferred / user_provided`), `last_verified_at`, `confidence` (0–1) on companies, contacts, vessels, owner/operator links, salary benchmarks |
| Enumerations | `VARCHAR` + `CHECK` constraints (easy to extend in migrations) |

**Integrity rule enforced by the database:** a row can only be `verified` if it has a
`source_url` **and** a `last_verified_at` date (`ck_*_verified_requires_source`). Fabricated
data cannot be stored as verified.

### Entity groups

| Group | Tables |
|---|---|
| Identity | `users`, `notification_preferences`, `audit_logs` |
| Candidate | `candidate_profiles` (several per user, one primary), `candidate_experience`, `candidate_certificates`, `candidate_documents` |
| Companies | `companies`, `company_websites`, `company_sources`, `company_industries`, `company_contacts`, `contact_sources`, `company_notes` |
| Fleet | `vessel_types` (shared reference data), `vessels`, `vessel_owners`, `vessel_operators` |
| Jobs & CRM | `vacancies`, `job_applications`, `application_status_history`, `follow_up_tasks` |
| Mail | `email_accounts` (encrypted refresh token, history id, watch expiry), `email_threads`, `email_messages`, `email_attachments` |
| Money | `salary_offers` (confirmed vs reported), `salary_benchmarks` (with monthly-normalised amount) |
| AI & search | `ai_conversations`, `ai_generated_drafts` (status `draft → approved → sent`), `search_history` |

Notable design decisions:

* **Owner ≠ operator ≠ employer.** `vessel_owners` and `vessel_operators` are separate link
  tables with validity dates; `vessel_operators.is_crewing_employer` is nullable (= unknown).
* **Duplicates** are merged, not deleted: `companies.merged_into_id`. The unique index on
  `(user_id, normalized_name, country_code)` ignores merged and deleted rows.
* **Email ↔ application links are never silent**: `email_threads.association_status` is
  `unlinked / suggested / confirmed / rejected`; only `confirmed` counts.
* **Duplicate mail prevention**: unique `(account_id, provider_message_id)` and
  `(account_id, provider_thread_id)`.
* **Inferred e-mails** use `company_contacts.email_status = 'inferred'` and can never satisfy
  the `verified` check without a source.
* **Workspace model**: research data (companies, contacts, vessels) is per user. This gives
  strict isolation and simple GDPR deletion. A shared, de-duplicated public catalogue can be
  added later as separate read-only tables without changing the per-user ones.

## 4. Authentication

1. The app signs in with **Supabase Auth** (e-mail + password now; Google sign-in in Phase 5).
2. Every API call carries `Authorization: Bearer <Supabase access token>`.
3. The backend verifies the token (`app/core/security.py`) via the project's **JWKS**
   (asymmetric keys, recommended) or the legacy **HS256 secret**, checking signature, expiry,
   audience `authenticated` and issuer `<SUPABASE_URL>/auth/v1`.
4. On the first valid request the backend provisions a `users` row keyed by the token's `sub`.
   Passwords never touch the backend.

## 5. Security model

* **Row-level security** – each request publishes the user id as the transaction-local
  setting `app.user_id`; policies `user_isolation` compare it with `user_id` (`USING` and
  `WITH CHECK`). `FORCE ROW LEVEL SECURITY` applies it to the table owner too. Queries also
  filter by `user_id` explicitly (defence in depth). **The production DB role must not be a
  superuser or have `BYPASSRLS`.** Tests prove isolation through a non-superuser role.
* **Secrets** only in environment variables / secret manager; `.env` is git-ignored.
* **Token encryption** – Gmail refresh tokens are stored as Fernet ciphertext
  (`TOKEN_ENCRYPTION_KEY`), never in plain text.
* **Input validation** with Pydantic (length limits, enums, date order).
* **Rate limiting** (in-process sliding window; move to the gateway/Redis for multiple replicas).
* **Security headers**, generic 500 responses (no stack traces), docs disabled in production,
  no wildcard CORS in production.
* **Audit log** of security-relevant actions (never message bodies or document contents).
* **Account deletion** (`DELETE /api/v1/me`, cascades all owned rows) and **data export**
  (`GET /api/v1/me/export`).
* **Outgoing e-mail approval** – enforced server-side in Phase 5: send endpoints accept only an
  approved draft id plus an explicit confirmation; there is no bulk-send endpoint.
* **Prompt-injection boundary** – e-mails and web pages are passed to Claude as quoted,
  untrusted data; AI tools cannot send mail or change records without a user action.

## 6. Navigation

Bottom navigation (phones) / navigation rail (tablet, web):

| Tab | Content |
|---|---|
| **Home** | Live dashboard counts, follow-ups, new companies, recent activity, Tools grid, Settings |
| **Discover** | Company / contact / vacancy discovery (Phase 3) |
| **Companies** | Employer database, fleet, contacts (Phase 3) |
| **Mail** | Gmail mail centre (Phase 5) |
| **Profile** | Candidate profiles, sea service (implemented) |

Secondary screens open from **Home → Tools** at `/tools/<id>`: CRM, Contacts, Fleet,
AI Assistant, Documents, Salary Database, Recruitment Map, Interview Trainer, Scam Detector,
Analytics. `/settings` holds account, server/integration status and account deletion.
Unbuilt modules show which phase they ship in — never sample data.

## 7. Design system

"Premium dark maritime": navy background `#070B14`, graphite surfaces `#0E141F / #141B28`,
1 px borders `#222C3D`, ice-blue accent `#8FD0F5`, radii 6/10/14 px, 4-pt spacing scale.
All tokens are in `app/lib/core/theme/tokens.dart`; components (`SsCard`, `SsStatTile`,
`SsBadge`, `SsMessageState`, `SsErrorState`, `SsPage`…) in `app/lib/core/widgets/widgets.dart`.
