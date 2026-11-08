/// Compile-time API base (no secrets). Override when building for a device on LAN:
/// `flutter run --dart-define=BNOOD_API_BASE_URL=http://192.168.x.x/api`
abstract final class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'BNOOD_API_BASE_URL',
    defaultValue: 'http://bnood.test/api',
  );

  static const subscriberAuthPrefix = '/v1/auth';
}
