# Security risks and mitigations

| # | Risk | Impact | Mitigation (status) |
|---|---|---|---|
| 1 | One user reads another user's data | Severe privacy breach | Per-request RLS context + `FORCE ROW LEVEL SECURITY` on 28 tables, plus explicit `user_id` filters; 404 for foreign ids. Tested end to end with a non-superuser role. **Deploy with a non-superuser DB role.** (✅) |
| 2 | Stolen / forged access tokens | Account takeover | Signature, expiry, audience and issuer checks; short-lived Supabase tokens with refresh; HTTPS only (HSTS in production). (✅) |
| 3 | Leaked secrets (Claude key, Google secret, DB password) | Cost abuse, data access | Secrets only in env/secret manager; `.env`, keystores and Firebase configs git-ignored; nothing secret in the Flutter build; CI uses repository secrets. (✅ policy, enforce in Phase 8 with secret scanning) |
| 4 | Gmail token theft from the database | Mailbox access | Refresh tokens encrypted with Fernet; key held outside the DB; minimum scopes; revoke on disconnect. (Phase 5) |
| 5 | AI sends an e-mail or attachment the user did not approve | Reputational / privacy harm | No auto-send path: send requires an approved draft, full preview and explicit confirmation; no bulk send; attachments chosen by the user. (Phase 5–6, schema ready: `ai_generated_drafts.status`) |
| 6 | Prompt injection via incoming e-mails or web pages | AI performs unwanted actions or leaks data | External text is passed as quoted untrusted data; AI tools are read-only or create drafts only; actions need user confirmation. (Phase 6) |
| 7 | Fabricated facts presented as verified (contacts, vacancies, salaries) | Wrong decisions, spam to wrong people | DB constraint: `verified` requires source URL + date; inferred e-mails flagged; vacancies `unverified` until checked; reports split facts vs assumptions. (✅ constraint) |
| 8 | Scraping that violates site terms / GDPR | Legal risk, IP bans | robots.txt, rate limits, official sources and APIs, no login/anti-bot bypass, personal contact data limited to professional public information with source. (Phase 3) |
| 9 | Sensitive documents (passport, medical) exposed | Identity theft | Private Supabase Storage bucket, owner-only signed URLs with short expiry, encryption, MIME/size checks, no automatic attachment. (Phase 7) |
| 10 | Brute force / abuse | Availability, cost | Rate limiting (per-process now; gateway/Redis in Phase 8); Supabase Auth's own limits. (🟡) |
| 11 | Error messages leak internals | Information disclosure | Generic 500 handler, no stack traces, docs disabled in production. (✅) |
| 12 | Scam recruiters | Financial / personal harm to the user | Scam detector with evidence, never a verdict on one weak signal. (Phase 7) |
| 13 | GDPR obligations | Legal | Export + deletion endpoints, analytics only with consent (`users.consent_analytics`), audit trail without content, retention policy for mail mirrors. (🟡 export covers implemented domains) |
