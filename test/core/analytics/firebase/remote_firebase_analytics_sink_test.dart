import 'package:bnood/core/analytics/domain/analytics_event.dart';
import 'package:bnood/core/analytics/domain/analytics_user.dart';
import 'package:bnood/core/analytics/firebase/ga_user_properties.dart';
import 'package:bnood/core/analytics/firebase/remote_firebase_analytics_sink.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/analytics/fake_firebase_analytics_gateway.dart';

void main() {
  late FakeFirebaseAnalyticsGateway gateway;
  late RemoteFirebaseAnalyticsSink sink;

  setUp(() {
    gateway = FakeFirebaseAnalyticsGateway();
    sink = RemoteFirebaseAnalyticsSink(gateway: gateway);
  });

  test('track logs GA event name and params for accepted events', () async {
    await sink.track(const ClientCreated(source: ClientCreatedSource.remote));
    await sink.track(
      const ScreenViewed(screenName: '/clients/:id'),
    );

    expect(gateway.events.length, 2);
    expect(gateway.events[0].name, 'client_created');
    expect(gateway.events[0].parameters, {'source': 'remote'});
    expect(gateway.events[1].name, 'screen_viewed');
    expect(gateway.events[1].parameters, {'screen_name': '/clients/:id'});
  });

  test('track maps subscription revenue as num', () async {
    const event = SubscriptionStarted(packageSlug: 'annual', revenue: 499.0, currency: 'EGP');
    await sink.track(event);

    expect(gateway.events.single.parameters, {
      'package_slug': 'annual',
      'revenue': 499.0,
      'currency': 'EGP',
    });
  });

  test('accepts rejects SignupCompleted (AppsFlyer only)', () {
    expect(sink.accepts(const SignupCompleted()), isFalse);
    expect(sink.accepts(const StatementShared()), isTrue);
  });

  test('setUser sets id and truncates name and phone to 36 chars', () async {
    const longName = 'abcdefghijklmnopqrstuvwxyz0123456789EXTRA';
    const longPhone = '+2012345678901234567890123456789EXTRA';
    await sink.setUser(
      const AnalyticsUser(id: 'user-42', name: longName, phone: longPhone),
    );

    expect(gateway.userIds, ['user-42']);
    expect(gateway.userProperties.length, 2);
    expect(gateway.userProperties[0].key, GaUserProperties.accountName);
    expect(gateway.userProperties[0].value, longName.substring(0, gaUserPropertyMaxLength));
    expect(gateway.userProperties[1].key, GaUserProperties.accountPhone);
    expect(gateway.userProperties[1].value, longPhone.substring(0, gaUserPropertyMaxLength));
  });

  test('setUser clears id and properties on logout', () async {
    await sink.setUser(const AnalyticsUser(id: 'user-1', name: 'Name', phone: '+20'));
    await sink.setUser(null);

    expect(gateway.userIds.last, isNull);
    final tail = gateway.userProperties.sublist(gateway.userProperties.length - 2);
    expect(tail[0].key, GaUserProperties.accountName);
    expect(tail[0].value, isNull);
    expect(tail[1].key, GaUserProperties.accountPhone);
    expect(tail[1].value, isNull);
  });
}