import 'package:bnood/core/analytics/domain/analytics_config.dart';
import 'package:bnood/core/analytics/domain/analytics_user.dart';
import 'package:bnood/core/analytics/domain/noop_analytics_service.dart';
import 'package:bnood/core/analytics/providers/analytics_providers.dart';
import 'package:bnood/core/storage/session_store.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../support/analytics/fake_analytics_service.dart';
import '../../../support/fake_session_store.dart';

User _user(String id) => User(
      id: id,
      phone: '+201000000001',
      name: 'Test User',
      phoneVerifiedAt: DateTime.utc(2026),
    );

void main() {
  test('analyticsServiceProvider returns Noop when analytics disabled', () {
    expect(AnalyticsConfig.enabled, isFalse);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final service = container.read(analyticsServiceProvider);
    expect(service, isA<NoopAnalyticsService>());
  });

  test('analyticsLifecycleProvider sets and clears user', () async {
    final fake = FakeAnalyticsService();
    final container = ProviderContainer(
      overrides: [
        sessionStoreProvider.overrideWithValue(FakeSessionStore()),
        analyticsServiceProvider.overrideWithValue(fake),
      ],
    );
    addTearDown(container.dispose);

    container.read(analyticsLifecycleProvider);
    await Future<void>.delayed(Duration.zero);

    final auth = container.read(authControllerProvider.notifier);
    auth.adoptSessionForTest(_user('user-1'));
    await Future<void>.delayed(Duration.zero);

    expect(
      fake.users.whereType<AnalyticsUser>().last,
      const AnalyticsUser(id: 'user-1', name: 'Test User', phone: '+201000000001'),
    );

    await auth.logout();
    await Future<void>.delayed(Duration.zero);

    expect(fake.users.last, isNull);
  });
}