# Bnood بنود

Flutter app for site/finishing engineers: client fund balances, vouchers, suppliers, craftsmen, and statements — with Arabic/English UI and online API sync.

## Local setup

- **Flutter:** [FVM](https://fvm.app/) — project pins **3.41.1** (`.fvmrc`).
- **Codegen:** Drift + flutter_gen — run after pulling schema/asset changes:

```bash
fvm flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

- **Run (dev API):**

```bash
fvm flutter run --dart-define-from-file=.env.dev
```

See [.vscode/launch.json](.vscode/launch.json) for **Bnood (dev)** / **Bnood (prod)**. API base URL: `lib/core/config/api_config.dart` and root `.env.dev` / `.env.prod` (public URLs only).

## Documentation

Product and architecture docs live under [`docs/`](docs/) — start with [scope](docs/scope.md) and [architecture](docs/architecture.md). Cursor rules: [`.cursor/rules/`](.cursor/rules/).

## Release & CI/CD

- **Branching and tags:** `main` ships; tags `vX.Y.Z` only from `main` after merging `develop`. Details: [`.cursor/rules/release-ci.mdc`](.cursor/rules/release-ci.mdc).
- **CI:** [Codemagic](https://codemagic.io/) runs **iOS** (TestFlight) and **Android** (Play internal) on `v*` tag push. Configure integrations and secrets in the UI — step-by-step: [`docs/codemagic-setup.md`](docs/codemagic-setup.md).
- **Typical release:** merge to `main` → `git tag v1.0.2` → `git push origin v1.0.2` (when approved). Build numbers come from the stores, not `pubspec.yaml`.
- **Retry one platform:** Codemagic **Start new build**, pick `ios-release` or `android-release`, branch `main`, set `VERSION_NAME` to the semver (e.g. `1.0.1`).
