# Nav restructure — Home, Projects, Providers, More

**Status:** planning only. No code in this pass.
**Branch context:** `feature/office-m1` (local).
**Date:** 2026-11-23.

Marks: **Confirmed** = in the repo or backend today. **Proposal** = recommended shape for implementation. **Open** = Osama decides before or during the named slice.

This plan supersedes the four-tab map in [ux-flows.md](../ux-flows.md) and `.cursor/rules/bnood-ux-navigation.mdc` only after a slice ships. Those files stay unchanged until then.

---

## 1. Current state (Confirmed)

### Shell

`go_router` `StatefulShellRoute.indexedStack` in `lib/app/router.dart`. The shell page is `NoTransitionPage`. Tab bodies stay mounted. `ShellScaffold` paints:

| Width | Chrome |
|---|---|
| Phone and tablet (`isDesktopLayout` false; tablet is above mobile max and at or below tablet max) | `FloatingShellDock` pill + voucher satellite |
| Desktop (`isDesktopLayout`) | `ShellNavigationRail` (min width 100). No floating dock. Voucher is the rail leading disc. |

Dock highlight uses `AnimatedContainer` + `AppMotion.stateSwap`. That is a fill fade on the selected slot, not a route transition.

`AppShellTabId`: `home`, `clients`, `directory`, `items`. All four `appShellTabOnlineProvider` flags are true.

| Index | Path | Body | Nav label (AR / EN) | Icon |
|---|---|---|---|---|
| 0 | `/home` | `HomeScreen` | الرئيسية / Home | `homeOutline` |
| 1 | `/clients` | `ClientsListScreen` | العملاء / Clients | `clientsOutline` |
| 2 | `/directory` | `AppShellDirectoryBody` → `ProvidersScreen` | الدليل / Directory | `directoryOutline` |
| 3 | `/items` | `AppShellItemsBody` → `ItemsScreen` | البنود / Items | `itemsLayersOutline` |

Satellite **+** (`navAdd`: جديد / New) opens a fresh voucher. It is not a tab.

`/directory?tab=craftsmen` is parsed in the router (`initialTabIndex: 1`) and then dropped: `AppShellDirectoryBody` always returns `const ProvidersScreen()`. Existing gap. Do not expand it in the nav slices unless the directory route is edited anyway.

Nav labels are asserted as one word (`test/shell_nav_labels_test.dart`).

### Routes outside the shell (must keep working)

Root `GoRoute`s, not tabs:

- Client: `/clients/:clientId`, `/movements`, `/craftsmen`, `/suppliers`, `/items`, `/statement`
- Provider: `/providers/:providerId`; redirects `/suppliers/:id` and `/craftsmen/:id` → `/providers/:id`
- Auth and menu: `/profile`, `/settings` (`AppMenuScreen`), `/settings/preferences`, `/settings/notifications` (`NotificationSettingsScreen` — push **preferences**, not an inbox)
- Content: `/pages/:slug` (about, terms, privacy, cancellation)
- `VoucherScreen.path`
- Push pseudo-route `/subscription` (`push_payload_routing.dart`) is not a `GoRoute`. `PushCoordinator` presents the paywall.

`authenticatedHomeFor` returns `/home`.

### Analytics screen names

`analyticsScreenNameForRoute` uses `Route.settings.name`, which go_router sets to the matched path (`/home`, `/clients`, `/clients/:clientId`, …). Popup routes are skipped. Shell branches each get `AnalyticsRouteObservers.forShellBranch`. Renaming a path changes the Firebase `screen_name`. **Proposal:** do not rename existing paths.

### Account context (M1)

- `AccountScope`: personal, or one office id. Persisted in SharedPreferences (`bnood.account.selection`) via `AccountContextStore`. Only the **current** scope is stored. There is no previous-scope key.
- `AccountContextController.selectPersonal` / `selectOffice`. A change runs `resetAccountScopedState`.
- Memberships: `auth/me` → `office.offices` via `AppOfficeMembershipPayloadService`. Each row has `id`, `name`, `read_only`, `status`, `role`, `permission_keys`, `web_access`, `dashboard_url`. **No `logo_url`.** The service also **skips offices without `web_access`**, so the phone list is not “every office the user belongs to” unless every membership has web access.
- Switcher UI: `showAccountSwitcherSheet` → `AppSheet.choices` (`accountSwitchTitle`: Choose account / اختيار الحساب). Hidden when `accountSwitcherVisibleProvider` is false (no offices, or locked to the owned office).
- Entry points today: home header `AccountSwitcherTitle` (chevron on the title), and a Menu row `accountSwitchMenu`.
- Home header otherwise: `HomeIdentityTitle` (greeting, name, `UserIdentityAvatar` from `user.logoUrl`, initials via `personInitials`, optional premium color). Trailing action is the menu glyph → `context.push(AuthPaths.settings)`.
- Office dashboard: `officeDashboardLaunchProvider` → external URL (`officeOpenDashboard`). Not an in-app route.
- `GET /v1/office/session` returns `logo_url` (`OfficeProfileIdentity::sessionOfficePayload`). The Flutter app does not call it.

Personal logo: `User.logoUrl` from profile. Office logo files exist on the office (`OfficeProfileIdentity::LOGO_COLLECTION`) but are not on the membership JSON the app parses.

### Menu (`/settings`)

`AppMenuBody` sections:

1. Account (profile or login), Subscription (if surfaces on), Settings (theme + language at `/settings/preferences`), Account switch (if switcher visible), Open dashboard (if URL), Notification settings (if signed in).
2. Content: about, terms, privacy, cancellation.
3. Sign out (confirm via existing logout flow).

Theme and language are not on the menu root. They live on preferences.

### What “projects” and “clients” are today

There is **no** mobile projects list.

- Subscriber API (`/api/v1/clients`) is the ledger list. Client JSON may embed one auto `project`. Client detail is the project UI ([ux-flows.md](../ux-flows.md)).
- Subscriber API has statement routes under `/api/v1/projects/{id}` only. No subscriber projects index.
- Office **web** API has both `/api/v1/office/clients` and `/api/v1/office/projects`. The phone does not call the office projects index.

Folder assets already in the set: `projectFolderOutline`, `folderAddOutline`. No bell / notification glyph. Closest empty-state icon: `emptyInboxOutline`.

### Notifications (app + `bnood-admin`)

**No inbox.** Confirmed absent:

- No `GET /api/v1/notifications` (requested only as a proposal in [office-mobile-plan.md](../office-mobile-plan.md) M5).
- No notification model, list screen, or unread field on the Flutter account payload.
- `GET /api/v1/accounts` from that plan is not a route.

What does exist:

- `GET/PATCH /api/v1/notification-settings` and the settings screen (master toggle, low-balance).
- `POST/DELETE /api/v1/device-tokens`.
- FCM data routing: `low_balance` → `/clients/{id}`, `subscription_expiry` and broadcast target `subscription` → paywall, else `/home`.
- Admin-only `broadcast-notifications` (staff send). Not a user inbox.
- Command `notifications:subscription-reminders` sends a push. It does not store a list the app can read.

**Proposal:** app-bar control opens a placeholder empty state. Do not invent an inbox API in the nav slices.

---

## 2. Proposed structure

### Tab map (Proposal)

Four destinations. Voucher satellite stays. Same dock and rail.

| Index | Tab | Path (stable) | Screen | Icon |
|---|---|---|---|---|
| 0 | Home | `/home` | `HomeScreen` | `homeOutline` |
| 1 | Projects | `/clients` | **Same** `ClientsListScreen` until a real projects index exists | `projectFolderOutline` |
| 2 | Providers | `/directory` | `ProvidersScreen` (suppliers + craftsmen) | `directoryOutline` (keep until a new mapping is approved) |
| 3 | More | `/more` (new) | More list (menu + modules) | Context avatar, not an SVG |

`AppShellTabId` becomes `home`, `projects`, `providers`, `more`. `projects` still gates the clients list. Drop `items` from the shell enum.

**Why `/clients` stays the Projects path:** the list on that route is the only project surface on the phone. A second path would fork analytics and push routing for the same screen. The visible label and icon change; the route does not.

**Clients row inside More:** **Proposal:** do not add it while it would open the same list as the Projects tab. See Open Q1. If Osama later wants a distinct client directory, that is a new screen and a new path, not a second mount of `ClientsListScreen`.

**Items:** leave the shell. Keep path `/items` as a root `GoRoute` (full screen, back to More). More row pushes `/items`. Deep link `go('/items')` still resolves. Analytics name stays `/items`.

**`/settings`:** **Proposal:** `redirect` to `/more` so old menu links and the home hamburger’s old target land on the tab. Menu widget moves into the More branch. Preferences stay at `/settings/preferences`. Notification **settings** stay at `/settings/notifications`.

### Route tree (Proposal)

```text
StatefulShellRoute.indexedStack          NoTransitionPage → ShellScaffold
  branch /home                           HomeScreen
  branch /clients                        ClientsListScreen     // label: Projects
  branch /directory                      ProvidersScreen       // label: Providers
  branch /more                           MoreScreen            // AppMenuBody + module rows
GoRoute /items                           ItemsScreen           // was a branch
GoRoute /settings                        redirect → /more
GoRoute /notifications                   NotificationsPlaceholderScreen   // new, not settings
…existing client, provider, auth, content, voucher routes unchanged
```

`goBranch` only. Do not add `CustomTransitionPage` on the shell. Re-tapping the active tab keeps the branch stack (`goBranch` default `initialLocation: false`).

Page swap is already instant. **Proposal:** leave the pill fill’s `AppMotion.stateSwap` as is. That motion is selection chrome, not a screen transition.

### Where each existing screen moves

| Screen | Now | After |
|---|---|---|
| Home | Tab 0 | Tab 0. Menu action becomes the notifications action. Header switcher stays (Open Q3). |
| Clients list | Tab 1 | Tab 1, labeled Projects. App bar title can stay the list’s own title until copy is updated in that slice. |
| Providers directory | Tab 2, label Directory | Tab 2, label Providers. Screen title stays `directoryTitle` (الموردين والصنايعية / Directory). |
| Items | Tab 3 | Pushed `/items` from More. |
| Menu | Pushed `/settings` | More tab. `/settings` redirects. |
| Profile, subscription paywall, preferences, notification settings, content pages, logout, office dashboard | Menu rows | Same rows on More. Same routes and `launchAllowedUrl`. |
| Client detail, movements, statement, provider detail, voucher | Root routes | Unchanged. |
| Home identity avatar | Home header | Stays. More tab uses a smaller circle of the same data. |

### More screen contents (Proposal)

Reuse `AppMenuBody` inside `ShellTabScaffold` (no back button). Add a **Modules** section above the account section:

- Items → `/items` (`itemsLayersOutline`, label `navItems` until a longer row label is needed).
- Clients → **only if Q1 says it is a different screen.** Otherwise omit.

Keep account, subscription, settings, account switch, open dashboard, notification settings, content, logout. Account-switch row stays so the control exists without a long-press (accessibility and discoverability).

Empty and error rows use `AppFallback`. No new toasts for opening a tab.

### Labels (Proposal)

New arb keys. Keep old keys (`navClients`, `navDirectory`, `navItems`) so list screens and tests that still mean “clients” / “items” do not flip by accident. Tab strings are new.

| Key | AR | EN | Notes |
|---|---|---|---|
| `navProjects` | المشاريع | Projects | One word. Tab only. |
| `navProviders` | المزودون | Providers | One word. Tab only. Screen title unchanged. |
| `navMorePersonal` | أنت | You | Personal mode. |
| `navMoreOffice` | المكتب | Office | Office mode. **Recommended.** |

Office-mode alternatives (Osama picks, Open Q2):

| Option | AR / EN | Why it loses or wins |
|---|---|---|
| **المكتب / Office (recommended)** | One word. Says the mode, not the person’s name. Distinct from the office’s proper name in the home header. |
| الحساب / Account | Collides with Menu “Account” (`authAccountSection`) and “Choose account”. |
| الفريق / Team | The phone has no team management. A member is not the team. |

Dynamic office name as the tab label: overflows the one-word dock, changes width per office, and duplicates the header. Do not use it.

RTL: labels use the dock’s existing center column. Avatar photo is not mirrored. Initials use `personInitials` (first Arabic glyph is fine). Layout stays logical start/end. No `TextDirection.ltr` on the tab label.

### Notifications placement (Proposal)

Trailing `CustomAppBarAction` on **shell tab** app bars (Home, Projects, Providers, More), replacing the menu glyph. Detail screens keep their own actions and back button.

- Icon: `emptyInboxOutline` until a bell asset is approved (Open Q5). Semantics: الإشعارات / Notifications (`notificationSettingsTitle` is already “Notifications” / «الإشعارات» — reuse that string for the button, or add `navNotifications` if the settings title must diverge).
- Route: `/notifications` → placeholder `Scaffold` + `AppFallback` (icon `emptyInboxOutline`, title, short description that alerts will show here). No skeleton (no fetch). No badge.
- Do not reuse `/settings/notifications`. That screen edits toggles.
- Push taps keep today’s routes (`/clients/{id}`, paywall, `/home`). The placeholder is not the push destination.

### Context avatar tab (Proposal)

`ShellNavDestination.icon` is an `SvgGenImage` today. Add an optional leading widget so the More slot can ignore the SVG. Dock and rail both read it. Selected state: primary ring (1.5) around the circle when that branch is active. Do not `ColorFilter` the photo. Unselected: no ring, label muted, same as other tabs.

**Sources**

- Personal: `UserIdentityAvatar` data — `user.logoUrl`, else initials from the display name. Skip the premium violet fill on the 22–24px dock circle (it stays on Home and Profile). Size ≈ `AppSize.iconCompact`.
- Office: initials from `selectedOfficeMembershipProvider.name` via `personInitials`. If `logo_url` is later added to the membership JSON, show it with the same error fallback as `UserIdentityAvatar`. Until then, initials only. Do not call office session from the tab.

**When the switcher is hidden** (`accountSwitcherVisibleProvider` false): the avatar still shows the current context. Long-press and double-tap do nothing. No sheet with a single disabled row.

### Gestures (Proposal)

`GestureDetector` with both `onTap` and `onDoubleTap` **delays the tap** by the double-tap timeout. That fights instant tab switching. Do not register both.

Use one tap recognizer that runs immediately, plus a timestamp:

1. **Tap:** `goBranch(moreIndex)` in the same frame. If the previous tap on this slot was within 300ms, also run the quick switch (step 3). First tap never waits.
2. **Long-press** (default ~500ms): if the switcher is visible, `HapticFeedback.mediumImpact()` and `showAccountSwitcherSheet`. The tap recognizer loses to the long-press, so the tab does not also toggle. If the switcher is hidden, no haptic and no sheet.
3. **Quick switch (second tap inside 300ms):** if the switcher is visible, `HapticFeedback.lightImpact()` and select the previous scope. Selection still goes through `AccountContextController` (cache reset stays as today).

**Previous scope:** new prefs key next to `bnood.account.selection`, written only after a successful select, storing the scope that was current before the write. Double-tap selects that value when it is still personal or still in `officeMembershipsProvider`. If it is missing or stale, do nothing (do not cycle a third office). With exactly one office and no stored previous, previous means the other of {personal, that office}. Owned-office lock: quick switch no-ops, same as the sheet.

**Haptics:** `AppPressable` already fires `selectionClick` on press. The More slot should use the same pressable for the tap so the tab haptic matches the other three. Add medium impact only when the sheet actually opens, and light impact only when the scope actually changes. Do not stack a second click on those paths.

**Accessibility:** `Semantics(button: true, selected: …, label: navMorePersonal or navMoreOffice)`. TalkBack / VoiceOver double-tap is Activate, and that must **only** select the tab. Put quick-switch on the pointer timestamp, not on `onDoubleTap`. Expose `SemanticsAction` (or a long-press `onLongPress` hint) “Choose account” that calls the same sheet. Hint string is new l10n, both locales.

**Rail:** `NavigationRailDestination` has no long-press. Build the More icon as a custom child (same avatar widget and recognizers) inside the destination `icon` / `selectedIcon`. Indicator and label stay on the rail. Phone dock and desktop rail share one widget (`ContextNavAvatar`). Tablet stays on the dock, so it gets the same gestures without a rail port.

**Sheet:** no new switcher. `AppSheet.choices` already uses the modal sheet shell. Add avatar or initials as `SheetChoice.leading` when cheap; the checkmark for the active row stays. Office rows still use the membership name.

### Responsive

No new breakpoint. Desktop rail destinations stay in the same order, including the avatar slot and the voucher leading button. Dock clearance and gradient stay. Keyboard still hides the dock (`ShellScaffold`).

### Docs to touch in the implementation slice (not now)

- [ux-flows.md](../ux-flows.md) primary-nav table
- [docs/assets/nav-icon-mapping.md](../assets/nav-icon-mapping.md)
- `.cursor/rules/bnood-ux-navigation.mdc` (owner override text)
- README index line for this plan, when docs are allowed to change

---

## 3. Implementation slices

Order is the dependency order. Sizes are relative (files and risk), not calendar time.

### Slice A — Shell destinations (M)

Relabel tab 1 to Projects (`projectFolderOutline`), tab 2 to Providers, add `/more` branch, move `/items` to a root route, redirect `/settings` → `/more`, point More at `AppMenuBody` plus an Items row. Replace the shell menu glyph with a disabled or hidden slot only if Slice B is not in the same PR; otherwise land B with A so Home is not left without an action.

Tests: `shell_nav_labels_test` (new one-word labels, AR+EN), `shell_scaffold_nav_test` branch paths, router redirect still sends an authenticated user to `/home`, `/items` and `/clients/:id` still match, `/settings` redirects.

Risk: branch index changes break any test that hard-codes index 3 as Items. Analytics gains `/more` and loses `/items` as a **shell** screen (the path `/items` remains). **Blocked on Q1 only for a Clients row.** The Projects label can ship on the current list without Q1.

### Slice B — Notifications placeholder (S)

`/notifications` empty state. `CustomAppBarAction` on the four shell app bars (Home’s menu button, the tab-gate placeholder, and the other tab scaffolds that show a bar). `AppFallback`, no request, no badge.

Tests: tap action pushes `/notifications`; fallback title uses the notifications string; settings route `/settings/notifications` still builds the toggles screen.

Risk: three or four app bars each grow an action. Miss one and Home still shows the hamburger.

### Slice C — Avatar slot and gestures (M)

`ContextNavAvatar` in dock and rail. Instant tap, long-press sheet, timestamp quick-switch. Semantics action for the sheet. Haptics as above. Previous-scope prefs in `AccountContextStore`.

Tests: tap calls `goBranch` and does not wait; two taps inside 300ms call `selectPersonal` / `selectOffice` once; stale previous id does not throw; long-press opens the sheet and does not change branch by itself; switcher hidden → long-press and second tap no-op; rail and dock share the widget; AR and EN semantics labels.

Risk: recognizer arena vs `AppPressable` (tap + long-press). Prove it in a widget test on a narrow width. Desktop rail hit target is the icon slot, not the whole rail row — match the other destinations’ icon size (27).

### Slice D — More composition polish (S)

Only if A landed the menu body raw. Order sections (modules, then account, then content, then logout). Drop the duplicate hamburger. Keep the Account row.

Risk: low. Do not redesign settings rows.

### Explicitly out of this plan

Inbox API, unread badges, office `logo_url` on `auth/me`, a real projects index, fixing `/directory?tab=craftsmen`, removing the home header switcher, changing voucher satellite placement.

---

## 4. Tests to add or update (checklist)

- `test/shell_nav_labels_test.dart` — Projects, Providers, You, Office are one word in AR and EN. `directoryTitle` stays the long Arabic string.
- `test/shell_scaffold_nav_test.dart` — four branches: `/home`, `/clients`, `/directory`, `/more`.
- `test/shell_navigation_rail_test.dart` — four destinations; More slot is the avatar, not `itemsLayersOutline`.
- New gesture test for `ContextNavAvatar` (cases in Slice C).
- `test/push_payload_routing_test.dart` — still `/clients/abc`. No edit expected.
- Router: `/settings` → `/more`; `/items` builds outside the shell; `/settings/notifications` unchanged.
- Account store test: previous scope round-trip; invalid id ignored.
- Widget: notifications placeholder has Western-digit-free copy (no amounts) and `AppFallback`.

Run with `fvm flutter test` on the touched files. No DB or env changes.

---

## 5. Risks

- **Projects vs Clients naming.** Shipping the folder icon on the client list is honest only if Osama accepts that list as Projects. A parallel Clients row that opens the same screen will look like a bug.
- **Membership list is web-access filtered** and has no logo. The avatar and the sheet cannot show “every office” or a logo until the payload changes. Initials are the fallback either way.
- **Quick-switch vs VoiceOver.** Binding account change to a platform double-tap would switch context when the user only meant to open More.
- **Tap delay.** A stock `onDoubleTap` would hold every More tap for ~300ms. The timestamp approach avoids that and must be the one that lands.
- **`/settings` redirect** changes the analytics name of the menu from `/settings` to `/more`. Call that out in the slice note. Preferences and notification settings paths stay.
- **Context switch already resets scoped providers.** Opening the sheet must not select. Only a picked row or a successful quick-switch calls the controller.
- **Dock height.** A 24px circle plus a label must fit `shellDockPillExtent` at text scale. The dock already `FittedBox`es when scale > 1.35. The avatar should use the same icon slot as `ShellNavIcon`, not `UserIdentityAvatar`’s 48px default.
- **Rule drift.** `bnood-ux-navigation.mdc` still says Home, Clients, Directory, Items. Update it in the same PR as Slice A so the next agent does not “fix” the new tabs back.

---

## 6. Open questions

1. **Projects tab vs Clients in More.** Recommendation: Projects tab is today’s client list (folder icon, path `/clients`). More does not repeat it. A separate Clients screen waits until the product has a second list. Confirm or reject.
2. **Office More label.** Recommendation: «المكتب» / Office. Reject «الحساب» and «الفريق» unless you want one of those. Personal stays «أنت» / You.
3. **Home header switcher.** Recommendation: keep `AccountSwitcherTitle` in this work. Long-press on More is a second entry, not a removal. Remove the header control only if you want one switcher.
4. **Notifications icon scope.** Recommendation: all four shell app bars, not Home only. Detail screens unchanged.
5. **Icon asset.** Recommendation: `emptyInboxOutline` for the placeholder and the app-bar action until a bell SVG is added. `projectFolderOutline` for Projects. Keep `directoryOutline` for Providers.
6. **Quick-switch target.** Recommendation: last scope only (new prefs key). If none is stored and there is one office, toggle personal ↔ that office. Never cycle through three or more.
7. **Office logo.** Recommendation: initials until `auth/me` offices include `logo_url`. No extra session request from the tab.
