import 'package:bnood/core/push/push_cold_start_navigation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stages first cold-start source only until consumed', () {
    final nav = PushColdStartNavigation();
    nav.stage(fcm: {'type': 'subscription_expiry'});
    nav.stage(local: {'type': 'broadcast', 'target': 'app'});
    expect(nav.pending?['type'], 'subscription_expiry');

    final data = nav.takePending();
    expect(data?['type'], 'subscription_expiry');
    expect(nav.pending, isNull);
    expect(nav.hasPending, isFalse);

    nav.stage(fcm: {'type': 'low_balance'});
    expect(nav.pending, isNull);
  });

  test('shouldIgnoreOpenedApp after cold start consumed', () {
    final nav = PushColdStartNavigation();
    final payload = {'type': 'subscription_expiry'};
    nav.stage(fcm: payload);
    nav.takePending();
    expect(nav.shouldIgnoreOpenedApp(payload), isTrue);
    expect(nav.shouldIgnoreOpenedApp({'type': 'low_balance'}), isFalse);
  });
}
