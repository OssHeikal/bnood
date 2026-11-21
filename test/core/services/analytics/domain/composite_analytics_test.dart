import 'package:bnood/core/services/analytics/domain/analytics_accept_policies.dart';
import 'package:bnood/core/services/analytics/domain/analytics_event.dart';
import 'package:bnood/core/services/analytics/domain/composite_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/analytics/policy_recording_analytics_sink.dart';

void main() {
  late PolicyRecordingAnalyticsSink firebaseSink;
  late PolicyRecordingAnalyticsSink appsFlyerSink;
  late CompositeAnalytics composite;

  setUp(() {
    firebaseSink = PolicyRecordingAnalyticsSink(firebaseAcceptPolicy);
    appsFlyerSink = PolicyRecordingAnalyticsSink(appsFlyerAcceptPolicy);
    composite = CompositeAnalytics(sinks: [firebaseSink, appsFlyerSink]);
  });

  test('SignupCompleted reaches only AppsFlyer-policy sink', () async {
    await composite.track(const SignupCompleted());

    expect(appsFlyerSink.events, [isA<SignupCompleted>()]);
    expect(firebaseSink.events, isEmpty);
  });

  test(
    'ScreenViewed, ClientCreated and StatementShared reach only Firebase-policy sink',
    () async {
      await composite.track(const ScreenViewed(screenName: '/clients'));
      await composite.track(
        const ClientCreated(source: ClientCreatedSource.local),
      );
      await composite.track(const StatementShared());

      expect(firebaseSink.events.length, 3);
      expect(firebaseSink.events[0], isA<ScreenViewed>());
      expect(firebaseSink.events[1], isA<ClientCreated>());
      expect(firebaseSink.events[2], isA<StatementShared>());
      expect(appsFlyerSink.events, isEmpty);
    },
  );

  test('Subscription events reach both sinks', () async {
    const started = SubscriptionStarted(
      packageSlug: 'pro',
      revenue: 100,
      currency: 'EGP',
    );
    const renewed = SubscriptionRenewed(
      packageSlug: 'pro',
      revenue: 100,
      currency: 'EGP',
    );

    await composite.track(started);
    await composite.track(renewed);

    expect(firebaseSink.events, [started, renewed]);
    expect(appsFlyerSink.events, [started, renewed]);
  });

  test('a throwing sink does not block the others', () async {
    final throwing = ThrowingAnalyticsSink(firebaseAcceptPolicy);
    final working = PolicyRecordingAnalyticsSink(appsFlyerAcceptPolicy);
    final service = CompositeAnalytics(sinks: [throwing, working]);

    await service.track(const SignupCompleted());

    expect(working.events, [isA<SignupCompleted>()]);
  });
}
