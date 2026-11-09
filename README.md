# Bnood بنود

Foundation documentation for **Bnood** (formerly عهدة): a local-first mobile app for finishing/site engineers and contractors who manage client funds, work items, material suppliers, and labor craftsmen.

**Status:** V1 Flutter app (local-only) on branch `cursor/v1-implementation-edb5`. Foundation docs in PR #1.

## Documentation index

| Document | Summary |
|----------|---------|
| [Scope (V1 & V2)](docs/scope.md) | Product boundaries, in-scope vs deferred, localization |
| [Architecture](docs/architecture.md) | Flutter layout, modules, stack, repository pattern |
| [Data schema & invariants](docs/data-schema.md) | Entities, relationships, money rules, ER diagram |
| [UX & screen flows](docs/ux-flows.md) | Navigation, screens, vouchers, inline create, statements |
| [Design system](docs/design.md) | Theme, tokens, typography roles, Cairo/font notes |
| [Visual reference](docs/visual-reference.md) | index.html authority and nav override |
| [UI acceptance](docs/ui-acceptance.md) | Visual checklist and outstanding UI tasks |
| [Porting phase 1](docs/porting-phase1.md) | SmartRx SHA, boundaries, preview launch |
| [Shared components](docs/shared-components.md) | SmartRx reuse, AppCard/Amount/Fallback, sheets |
| [Static assets](docs/assets/README.md) | SVG icons, FlutterGen, `Assets.icons.*` usage |
| [Implementation plan](docs/implementation-plan.md) | Phased delivery and acceptance checks |
| [Open questions](docs/open-questions.md) | Unresolved product and technical decisions |
| [Confirmed decisions](docs/decisions.md) | Locked choices vs proposals |

## Cursor rules

Project rules live under [`.cursor/rules/`](.cursor/rules/). UI work: `bnood-impeccable.mdc` (global Impeccable), `bnood-ui-design.mdc`, `bnood-ui-components.mdc`, `bnood-ux-navigation.mdc`.

## Working agreements (standing)

- Ask before heavy cloud-agent cost; one cloud agent at a time.
- Planning: explicit Grok 4.7 / 4.6; implementation and doc edits: Composer 2.5 fast (`fast: false`); no Auto.
- **No application implementation** until explicitly approved beyond this documentation pass.

## Release builds

API base URL is compile-time via `BNOOD_API_BASE_URL` (`lib/core/config/api_config.dart`). Committed `.env.dev` / `.env.prod` at the repo root hold public URLs only (not in `.gitignore`).

**CLI (fvm):**

```bash
fvm flutter run --dart-define-from-file=.env.dev
fvm flutter build ipa --release --dart-define-from-file=.env.prod
fvm flutter build appbundle --release --dart-define-from-file=.env.prod
fvm flutter build apk --release --dart-define-from-file=.env.prod
```

- IPA: `build/ios/ipa/`
- App bundle (Play Store): `build/app/outputs/bundle/release/`
- APK: `build/app/outputs/flutter-apk/`

**IDE:** Run and Debug → **Bnood (dev)** or **Bnood (prod)** (`.vscode/launch.json` passes the same `--dart-define-from-file` paths).

If you omit the flag, the app uses the dev default `http://bnood.test/api` (same as `.env.dev`).

## Quick links

- V1: [local-only scope](docs/scope.md#v1-local-only)
- Money model: [piastres & balances](docs/data-schema.md#financial-invariants)
- Build order: [phase 1–5](docs/implementation-plan.md)
