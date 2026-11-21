/// Compile-time Sentry settings (`--dart-define` / `--dart-define-from-file`).
abstract final class SentryConfig {
  /// Non-empty only when CI/local passes `SENTRY_DSN` (never commit the value).
  static const dsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  /// Matches `BNOOD_APP_ENV` in `.env.dev` / `.env.prod` / Codemagic defines.
  static const environment = String.fromEnvironment(
    'BNOOD_APP_ENV',
    defaultValue: 'development',
  );

  static bool get isEnabled => dsn.isNotEmpty;
}
