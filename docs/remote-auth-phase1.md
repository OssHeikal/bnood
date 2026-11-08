# Remote auth (phase 1)

Flutter client talks to Laravel `POST/GET /api/v1/auth/*` (no `/mobile`). Domain models: `User` (phone app identity), `Staff` (admin backend); admin CRUD API paths remain `/api/admin/users`.

## API base URL

Configured at compile time via `BNOOD_API_BASE_URL` (`lib/core/config/api_config.dart`).

| Target | Example |
|--------|---------|
| Herd / Mac default | `http://bnood.test/api` (simulator cannot resolve `.test` — use LAN IP) |
| Physical device on LAN | `flutter run --dart-define=BNOOD_API_BASE_URL=http://192.168.x.x/api` |

Do not commit production URLs or tunnel endpoints. No secrets in defines (Bearer token is runtime-only in secure storage).

## Session

- Bearer token: `flutter_secure_storage` (`SessionStore`).
- Challenge IDs and `reset_token`: in-memory only (`AuthController`), never shown in UI.
- Wrong login/change-password does **not** clear an existing stored token.
- `/me` bootstrap network failure: retry UI; no fallback to local ledger.
- Authenticated users are routed to `/remote` only; local Drift routes redirect away.

## Tests

HTTP is mocked at the client boundary (`MockClient`). Secure store is faked in tests. No automated E2E against Herd in CI; run disposable backend manually if needed.

## Not in this phase

- Cloud ledger / sync UI
- Offline auth queue
- WhatsApp delivery copy when provider is unconfigured
