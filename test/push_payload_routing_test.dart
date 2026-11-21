import 'package:bnood/core/network/push/push_payload_routing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('low_balance routes to client detail when client_id present', () {
    expect(
      resolvePushNavigationLocation({
        'type': 'low_balance',
        'client_id': 'abc',
      }),
      '/clients/abc',
    );
  });

  test('low_balance without client_id falls back to home', () {
    expect(resolvePushNavigationLocation({'type': 'low_balance'}), '/home');
  });

  test('subscription_expiry routes to paywall', () {
    expect(
      resolvePushNavigationLocation({'type': 'subscription_expiry'}),
      pushSubscriptionLocation,
    );
  });

  test('broadcast target subscription routes to paywall', () {
    expect(
      resolvePushNavigationLocation({
        'type': 'admin_broadcast',
        'target': 'subscription',
      }),
      pushSubscriptionLocation,
    );
  });

  test('broadcast target app routes to home', () {
    expect(
      resolvePushNavigationLocation({'type': 'broadcast', 'target': 'app'}),
      '/home',
    );
  });

  test('unknown type opens home', () {
    expect(resolvePushNavigationLocation({'type': 'mystery'}), '/home');
  });
}
