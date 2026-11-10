# External services, credentials, costs and limitations

Nothing below is connected yet except where marked. Each integration reports its state at
`GET /health/ready` and in the app under **Settings → Server**.

## Required credentials

| Service | Needed for | Where it is configured | Secret? | Phase |
|---|---|---|---|---|
| Supabase project | Auth (sign-in), Storage (documents), optionally hosted Postgres | `SUPABASE_URL` (backend + app), `SUPABASE_PUBLISHABLE_KEY` (app), optional `SUPABASE_JWT_SECRET` (backend) | JWT secret: yes. Publishable key: no | 2 |
| PostgreSQL | Main database | `DATABASE_URL` | Password: yes | 2 |
| Fernet key | Encrypting Gmail refresh tokens | `TOKEN_ENCRYPTION_KEY` | Yes | 5 |
| Anthropic | AI assistant | `ANTHROPIC_API_KEY`, `ANTHROPIC_MODEL` (default `claude-opus-5-5`) | Key: yes | 6 |
| Google Cloud project | Gmail API, OAuth consent screen, Pub/Sub | `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GOOGLE_PUBSUB_TOPIC` | Client secret: yes | 5 |
| Firebase | Push (FCM; APNs key uploaded to Firebase) | `google-services.json`, `GoogleService-Info.plist`, server service account | Service account: yes | 7 |
| Apple Developer account | APNs key, iOS signing, App Store | Xcode / CI secrets | Yes | 7–8 |
| Google Play Console | Android release | upload keystore | Yes | 8 |
| Mapbox **or** Google Maps | Recruitment map | public token (app), restricted by bundle id / domain | Token restricted | 7 |
| PostHog | Product analytics (only with user consent) | project key | No (public) | 7 |
| Brave Search API | Discovery web search (optional; website research works without it) | `BRAVE_SEARCH_API_KEY` (backend) | Yes | 3 |

## Estimated running costs (single user / small team)

| Item | Estimate |
|---|---|
| Supabase | Free tier is enough for development; Pro plan ~$25/month for production backups and no pausing |
| Hosting API (Fly.io / Render / Cloud Run) | $0–15/month at low traffic |
| Claude API | Opus 5.5: $4 / $20 per million input/output tokens; Sonnet 5.5: $2 / $10; Haiku 5.5: $0.10 / $0.50. A cover letter (≈4k input incl. profile + company context, ≈1k output) ≈ $0.04 on Opus 5.5. 200 drafts/month ≈ $8. Prompt caching of the stable profile/system prompt cuts repeated input cost |
| Gmail API, Pub/Sub | Free within quotas for personal volume |
| Firebase Cloud Messaging | Free |
| Maps | Mapbox / Google Maps have free monthly tiers; personal use stays inside them |
| Search API | $0–30/month depending on provider and volume |
| Apple Developer Program | $99/year; Google Play one-off $25 |

## Technical limitations to plan for

* **Gmail restricted scopes.** Reading mail (`gmail.readonly` / `gmail.modify`) is a
  *restricted* scope: an app used by people outside your own Google Workspace needs Google
  verification and an annual third-party security assessment. For personal use, keep the
  OAuth app in *Testing* mode (max 100 test users, refresh tokens expire after 7 days) or
  publish as *internal*. Sending uses `gmail.send`.
* **Gmail Watch expires after ≤ 7 days** — a scheduled job renews it daily; a reconciliation
  job uses `history.list` from the last `history_id` and falls back to a full sync when the
  history id is too old.
* **Pub/Sub push** needs a public HTTPS endpoint; the backend verifies Google's push JWT.
* **LinkedIn and many job boards forbid scraping** in their terms. Discovery uses official
  pages, public registries and search APIs, respects `robots.txt` and rate limits, and never
  bypasses logins or anti-bot measures. LinkedIn URLs are stored only when the user adds them.
* **Fleet data** (IMO, ownership) from free public sources is incomplete; commercial databases
  are paid. The app shows provenance and "unknown" rather than guessing.
* **iOS builds** require macOS + Xcode; the cloud dev container builds Android/Web only.
* **Claude** responses can be refused or wrong; outputs are drafts that the user must review,
  and factual claims carry sources where possible.
