/// Compile-time API base (no secrets).
///
/// Prefer env files: `--dart-define-from-file=.env.dev` or `.env.prod`.
/// Single override: `--dart-define=BNOOD_API_BASE_URL=...` (wins over file keys).
abstract final class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'BNOOD_API_BASE_URL',
    defaultValue: 'http://bnood.test/api',
  );

  static const subscriberAuthPrefix = '/v1/auth';
}
