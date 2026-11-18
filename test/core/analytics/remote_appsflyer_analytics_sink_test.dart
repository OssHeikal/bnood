import 'package:bnood/core/analytics/analytics_config.dart';
import 'package:bnood/core/analytics/analytics_event.dart';
import 'package:bnood/core/analytics/analytics_providers.dart';
import 'package:bnood/core/analytics/analytics_user.dart';
import 'package:bnood/core/analytics/appsflyer_bootstrap.dart';
import 'package:bnood/core/analytics/appsflyer_event_mapping.dart';
import 'package:bnood/core/analytics/ga_user_properties.dart';
import 'package:bnood/core/analytics/remote_appsflyer_analytics_sink.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../support/fake_appsflyer_gateway.dart';

void main() {
  late FakeAppsFlyerGateway gateway;
  late RemoteAppsFlyerAnalyticsSink sink;

  setUp(() {
    gateway = FakeAppsFlyerGateway();
    sink = RemoteAppsFlyerAnalyticsSink(gateway: gateway);
  });

  test('track maps SignupCompleted to af_complete_registration', () async {
    await sink.track(const SignupCompleted());
    expect(gateway.events.single.name, appsFlyerCompleteRegistrationEvent);
  });

  test('track ignores non-signup events for now', () async {
    await sink.track(const ClientCreated(source: ClientCreatedSource.local));
    expect(gateway.events, isEmpty);
    expect(sink.accepts(const ClientCreated(source: ClientCreatedSource.local)), isFalse);
  });

  test('setUser sets customer id and vendor user data', () async {
    await sink.setUser(
      const AnalyticsUser(id: 'user-9', name: 'Osama', phone: '+201000000001'),
    );

    expect(gateway.customerUserIds, ['user-9']);
    expect(
      gateway.userDataSets.single,
      {
        GaUserProperties.accountName: 'Osama',
        GaUserProperties.accountPhone: '+201000000001',
      },
    );
  });

  test('setUser clears customer id and user data on logout', () async {
    await sink.setUser(null);
    expect(gateway.customerUserIds.single, '');
    expect(gateway.userDataSets.single, isEmpty);
  });

  test('appsFlyerGatewayProvider is null without dev key', () {
    expect(AnalyticsConfig.appsFlyerDevKey, isEmpty);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(appsFlyerGatewayProvider), isNull);
  });

  test('appsFlyerGatewayProvider is null when bootstrap not ready', () {
    AppsFlyerBootstrap.ready = false;
    addTearDown(() => AppsFlyerBootstrap.ready = false);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(appsFlyerGatewayProvider), isNull);
  });
}