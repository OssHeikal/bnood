# Office on the phone app

**Status:** planning only. This file is not implementation permission.
**Flutter:** `develop` @ `398fbc5` (remote API only; no Drift in `pubspec.yaml`).
**API:** `bnood-admin` `feature/office-phase1` @ `93add23`. Phases 1–3 of [office-dashboard-plan.md](file:///Users/macbook/Developer/bnood-admin/docs/office-dashboard-plan.md) are in that branch (offices, roles, memberships, project assignment, `office_id` + `created_by_user_id` on ledger tables, 20 permission keys, `view_scope`). No mobile office routes exist. Live `/api/v1` ledger queries still filter `user_id`.

Labels: **Confirmed** (product, already decided), **Proposal** (shape of the work), **Open** (do not build a guess).

Arabic UI labels stay in l10n. This plan is English.

---

## 1. Current state

One signed-in `User`. `SessionStore` keeps a single bearer (`bnood.subscriber.bearer`). `AuthInterceptor` adds `Authorization` only. Every feature API (`HomeApi`, `ClientsApi`, `ItemsApi`, `ProvidersApi`, `AgreementsApi`, `VouchersApi`, `SubscriptionApi`, `NotificationSettingsApi`, `DeviceTokensApi`, `AuthApi`) builds its own Dio via `createAppDio` and calls `/v1/...` with no tenant argument.

Riverpod read models are process-global, not keyed by account:

| Area | Providers |
|---|---|
| Home | `HomeTotalsNotifier`, `HomeClientBalancesNotifier`, `HomeSupplierSpendsNotifier`, `HomeCraftsmenNotifier`, `HomeSuppliersNotifier` (`SilentAsyncNotifier`) |
| Clients | `ClientsListNotifier`, `ClientDetailNotifier`, `ClientItemsStatsNotifier`, `ClientCraftsmenListNotifier` |
| Catalog | `ItemsCatalogNotifier`, provider/agreement repositories, `providerDetailProvider` (family by id only) |
| Money plan | `SubscriptionNotifier` ← `GET /v1/subscription` (one `user_subscriptions` row) |
| Push prefs | `NotificationSettingsNotifier` (master + low-balance; one row per user) |

`SilentAsyncNotifier` keeps the last payload on screen during refresh. That is correct for a refetch of the **same** account and wrong across accounts: the previous office’s clients would stay visible until the next response.

`AppVoucher` has no `created_by`. Home identity is the user’s name and logo and opens the profile. Shell is Home, Clients, directory, Items, plus the voucher satellite. Settings: profile, personal subscription paywall, preferences, push toggles, sign out. No team, roles, billing admin, invites, inbox, or account switcher.

Push (`push_payload_routing.dart`) understands `low_balance`, `subscription_expiry`, `broadcast`. The device token is registered once per user (`POST /v1/device-tokens`). There is no in-app notification list. Subscription expiry opens the personal paywall.

Gates today are personal-plan flags: `can_create_active_project`, `can_mutate_financial_transactions`, `can_archive_client`. They are not office permissions. `StatementExportStore` keys cursors by a constant workspace id plus entity id, not by office.

`docs/architecture.md` still describes Drift. The running app does not. Do not add a local tenant database for this work.

---

## 2. Architecture

**Confirmed.** One login. The switcher lists Personal plus each office (logo, role) and stays hidden until the first membership. Data for one account is never shown under another. The app remembers the last account. An office is visually marked so a voucher is not saved into the wrong one. Inside an office the same screens stay, hidden when the permission is off. All-scope roles see all office projects; own-only roles see assigned projects and only their own transactions. Every transaction shows who recorded it. No team, role, or billing management on the phone; **activity log is web-only** (no `activity_view` screen on the phone). Any office role with `web_access` gets **Open dashboard** (`https://office.bnoodapp.com`, normal web login — no shared session from the app). A lapsed office is read-only, still allows PDF, and shows a **read-only Home banner for all members**. Invites: WhatsApp from the office (Evolution; link is **landing only**) plus an in-app pending-invites list on **Personal** with accept and reject (only mobile accept path); after accept the office appears in the switcher. **Personal stays on the switcher after Pro → Business** — empty ledger, for invites and any other offices. Leave office from settings for non-owners; **Owner cannot leave**. `created_by` stays on past entries. Pro → Business: server computes discount and amount due; app displays only. Existing Pro rows move into the new office. Pushes arrive for every account. The in-app list is tagged and filtered by the selected account, with a per-account unread badge on the switcher. Personal renewal shows only in Personal. Office renewal shows only inside that office and only for the Owner. Invites show in Personal. **Low-balance alert settings are per account** (personal vs each office header scope). Account switch or push tap while a voucher sheet is open **switches immediately without a prompt** (draft discarded). If membership is revoked while the app is open, **fall back to Personal with a notice**. Preset roles: Owner (fixed), Admin, Accountant, Supervisor. Personal Free and Pro have no web access.

**Proposal — account context.** Add an `AccountContext` notifier beside `AuthController`. It does not replace the bearer.

- `personal` or `office` + office id (ULID).
- Selected membership: role key, role name, `is_owner`, permission set, `view_scope` (`all` | `own_transactions_only`), `projects_require_assignment`, office `status` (`active` | `read_only`), name, logo.
- Last account id in `SharedPreferences` (not secure storage). Theme and locale stay global.
- On launch: if the saved office is still in the membership list, select it; otherwise Personal.

**Proposal — how requests carry the account.** Header `X-Office-Id: <ulid>` on authenticated ledger calls, set in `AuthInterceptor` from `AccountContext`. Omit the header for Personal. Do not put the office id in the path and do not store the office on the Sanctum token for the phone. The web plan’s `POST /api/v1/office/context` pins one office on a token because the dashboard picks once. The phone switches often; a header cannot apply the previous office to the next in-flight call.

Server rules this client will assume (backend work, not in this repo yet):

- No header: `office_id` is null and `user_id` is the caller (today’s behavior).
- Header: caller is a member; rows are that office; project list follows assignment; voucher list follows `view_scope`; money fields are absent without `client_money`; writes fail when status is `read_only`.
- The phone does not re-filter a full office dump. Hiding a button is not the security boundary. A 403 still toasts.

**Proposal — cache reset on switch.** Account change is not a silent refresh. Invalidate home, clients, client detail families, items, providers, agreements, vouchers, the office-scoped subscription snapshot, notification list, and **per-account notification settings**. Drop list search/filter state. **Close any open voucher sheet without saving** — including when the user switches accounts or opens a notification target account (no confirm dialog). Do not leave the previous account’s `valueOrNull` on screen. Keep auth, theme, and locale.

**Proposal — permissions on device.** Personal Free/Pro ignores the office catalog and keeps today’s subscription gates. An office session uses the membership payload:

| Surface | Show when |
|---|---|
| Home money, balances, statement, PDF | `client_money` |
| Lapsed office banner (Home) | office `read_only` (all members) |
| Create voucher (satellite and row actions) | `voucher_create` and office `active` |
| Edit / delete voucher | `voucher_edit` / `voucher_delete` and office `active` |
| Clients / projects list (one screen) | `projects_view` |
| Add client / project | `projects_manage` and office `active` |
| Archive project | `projects_manage` and office `active` |
| Pick item in voucher | `voucher_create` (read catalog) |
| Item catalog add / edit | `items_manage` and office `active` |
| Directory list | `providers_view` **or** `providers_manage` (manage implies view) |
| Directory create/edit | `providers_manage` and office `active` |
| Open dashboard | `web_access` |
| Leave office | office context, not Owner |
| Team, roles, billing, office name/logo, activity log | never on phone |

Read-only (`read_only`) blocks every write above and still allows statement PDF. That flag is separate from a lapsed personal Pro (`can_mutate_financial_transactions`).

`created_by` `{ id, name }` on each voucher. The row subtitle shows the name. Own-only users only receive their rows, so the name is still shown.

---

## 3. Screen by screen

Same routes. No new shell tab.

| Screen | Change |
|---|---|
| Home title | Becomes the switcher control once the user has an office. Personal name/logo vs office name/logo and role. Office uses a visible badge (color plus name), including on the voucher sheet. **Read-only office:** banner for every member. Profile stays in settings. |
| Switcher sheet | Personal (including **empty Personal after Pro → Business**), then each office (logo, name, role, unread count). Hidden entirely at zero memberships, including while an invite is only pending. |
| Home, client list, client detail | Same layout. List requires `projects_view`; add requires `projects_manage`. Money blocks omitted without `client_money`. Project list is whatever the API returns (assigned vs all). Empty list for a member with no projects stays empty. |
| Movements and voucher detail | Secondary line: recorder name. Edit/delete follow the table above. |
| Voucher sheet | Writes disabled with the read-only reason when the office is lapsed. No extra “pick office” field; the sheet uses the current account. |
| Directory, items | Directory hidden without `providers_view` or `providers_manage`. Items tab: pick for voucher if `voucher_create`; catalog mutations only with `items_manage`. |
| Statement | Unchanged layout. PDF stays available when read-only if `client_money` is on. Hidden entirely without `client_money`. |
| Settings | **Leave office** for non-owners only. **Open dashboard** when `web_access` (external browser; user signs in on web). Notification settings screen respects **current account** (master + low-balance). |
| Personal only | Pending invites (office name, role, expiry, accept, reject). WhatsApp invite links do not deep-link accept — landing only. Personal paywall, including Pro → Business (server-priced). |
| Paywall inside an office | Does not sell a personal plan. Owner sees office status and the dashboard button. Other roles do not see billing. |
| New: notification list | One list, current account only. Row shows the account it belongs to when opened from a push that switched accounts. |

Copy and layout follow existing tokens (Cairo, teal, Western digits, `EGP`, logical start/end). Phone numbers and amounts stay LTR-isolated.

---

## 4. Notifications

Today the inbox does not exist. Pushes are not tagged with an office.

**Confirmed behavior**

- The device still registers one token for the user. Delivery is all accounts, including ones that are not selected.
- In-app list query is scoped to the selected account (same `X-Office-Id` rule).
- Switcher row shows that account’s unread count.
- `subscription_expiry` for the personal plan is stored and listed only on Personal, and the tap opens the personal paywall only in Personal.
- Office renewal is stored on that office and listed only for the Owner.
- Invite notifications are stored on Personal.

**Proposal — payload.** Keep `type`. Add `office_id` (omit when personal) and `notification_id`. New types: `office_invite`, `office_subscription_expiry`. Existing `low_balance` gains `office_id` when the client belongs to an office.

**Proposal — tap.** If the payload’s account is not selected, switch account immediately (full cache reset, voucher sheet closed without prompt), then run today’s route (`client_id` → client, personal expiry → paywall, office expiry → that office’s home, invite → Personal invites). Foreground banner text includes the account name.

---

## 5. API contract

None of these routes exist. This is the phone’s request. Ledger paths stay as they are.

| Proposal | Purpose |
|---|---|
| `GET /api/v1/accounts` | `personal` (name, logo, plan slug, unread), `offices[]` (id, name, logo, status, role, permissions, view_scope, projects_require_assignment, unread), `pending_invites[]` (id, office name, logo, role name, expires_at) |
| `X-Office-Id` | Tenant on existing `/api/v1` ledger, home, statement, and notification calls. Absent = personal |
| Voucher JSON `created_by` | `{ id, name }` on list and show |
| Money omission | No balance, receipt, or statement fields without `client_money` (web plan already says 403 / omit) |
| Write error `office_read_only` | Stable code when status is `read_only`. GET and statement PDF still succeed |
| `POST /api/v1/office-invites/{id}/accept` and `.../reject` | Caller must be the invited phone. Accept returns the office summary |
| `POST /api/v1/offices/{id}/leave` | Drops membership; **403 for Owner**. Rows keep `created_by_user_id` |
| `GET/PATCH /api/v1/notification-settings` | Same paths; scope by `X-Office-Id` (per-account low-balance and master toggles) |
| Membership revoked | Ledger calls return 403; client maps to “removed from office” and selects Personal with a toast |
| `GET /api/v1/notifications` | Page for the current header scope. Each item: id, type, title, body, read_at, created_at, target (client id or none) |
| `POST /api/v1/notifications/{id}/read` | Mark one read. Unread counts on `GET /accounts` change |
| `POST /api/v1/subscription/promote-business` | Personal Pro only. Server computes the amount due (remaining Pro time already discounted). Creates the office, moves the ledger, ends the personal paid row. Response is the new office summary |
| Paywall payload | Business row includes server `amount_due_minor` and a credit line. The app displays those numbers and does not prorate locally |

`GET /api/v1/subscription` stays the personal plan. Office status comes from `GET /accounts`, not from `user_subscriptions`.

Open dashboard is not an API. It opens `https://office.bnoodapp.com`.

---

## 6. Phases

Each slice is shippable only when its checkpoint tests pass. Backend routes can land in parallel; do not point a release build at production until the matching route is deployed. Tests use fakes at the API boundary, same as auth today (`fvm flutter test`).

**M1 — Context and header.** `AccountContext` defaults to Personal. Interceptor omits `X-Office-Id` for Personal and sets it for an office. No switcher. Checkpoint: interceptor unit tests; existing ledger tests unchanged.

**M2 — Switcher and isolation.** `GET /accounts`, last-account restore, sheet, home and voucher badge. Switch invalidates the provider set in §2 and does not silent-refresh. Checkpoint: widget test, zero offices hides the control; one office shows Personal + office; relaunch restores the last id; a switch does not paint the previous client name.

**M3 — Permissions, recorder, read-only.** Gate table in §2. `created_by` on movement rows. Lapsed office: Home banner, blocks save, statement PDF if allowed. Checkpoint: widget fixtures for Accountant (money visible, all projects), own-only (no foreign voucher), no `client_money` (no balance), `read_only` (banner + no save), `projects_view` without `projects_manage` (list, no add).

**M4 — Invites and leave.** Personal invite list, accept, reject, leave in settings (no leave for Owner). Checkpoint: accept adds the office to the switcher without relaunch; reject drops the row; leave selects Personal; Owner sees no leave row; a fixture voucher still shows the leaver’s name.

**M5 — Inbox and push.** List, badges, payload account switch, renewal and invite placement from §4. Checkpoint: list shows only the selected account; other-account tap switches then routes; personal expiry is absent inside an office; office expiry is absent for a non-owner fixture.

**M6 — Pro → Business.** Paywall action on an active personal Pro. Displays server amount due only. On success, select the new office; Personal remains on switcher with empty ledger. Checkpoint: hidden on Free and on an office session; success path selects office; Personal still listable.

**M7 — Open dashboard.** Settings row when `web_access`. Checkpoint: shown for Accountant/Supervisor presets with web flag; hidden without `web_access`; URL is `https://office.bnoodapp.com` with no bearer passed.

---

## 7. Risks

- A new `*Api` that forgets `createAppDio` / the shared interceptor will call the personal ledger while the UI shows an office.
- Silent refresh across a switch leaks the previous account. M2 has to invalidate, which is an intentional exception to the silent-refresh rule.
- Personal subscription cap (`GET /v1/subscription`) must not gate office project creation; office limits come from office billing, not this endpoint.
- One Evolution sender also sends OTP. Invite traffic is a backend rate-limit concern; the phone must not retry accept in a loop.
- `docs/architecture.md` and the V1 “no team” rule will be stale once this ships. Update them in the implementation slice, not in this plan.

---

## 8. Cross-repo conflicts (resolve in docs, not here)

| Topic | Web / admin plan | Mobile (confirmed) |
|---|---|---|
| Owner after Pro → Business | Owner has no personal ledger / personal home | **Personal stays on switcher** (empty) for invites and multi-office users |
| Open dashboard | Early text said Owner / Admin | **Any role with `web_access`** |
| Invite accept on phone | Evolution + landing link | Landing only; **accept/reject only in Personal pending invites** |
| `providers_view` vs manage | Supervisor preset omits `providers_view` | **`providers_manage` implies view** on mobile; backend catalog may still list both keys |

**Open (backend only):** exact Pro-time discount formula for `POST /subscription/promote-business` — not shown in the app, but billing must define it before charge goes live.
