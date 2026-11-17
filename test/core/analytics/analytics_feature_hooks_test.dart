import 'package:bnood/core/analytics/analytics_event.dart';
import 'package:bnood/core/analytics/analytics_feature_hooks.dart';
import 'package:bnood/core/analytics/analytics_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fake_analytics_service.dart';

void main() {
  late FakeAnalyticsService fake;
  late ProviderContainer container;

  setUp(() {
    fake = FakeAnalyticsService();
    container = ProviderContainer(
      overrides: [analyticsServiceProvider.overrideWithValue(fake)],
    );
  });

  tearDown(() => container.dispose());

  WidgetRef testWidgetRef() => _TestWidgetRef(container);

  test('trackClientCreatedAfterApi emits ClientCreated remote', () {
    trackClientCreatedAfterApi(testWidgetRef());
    expect(fake.events.single, const ClientCreated(source: ClientCreatedSource.remote));
  });

  test('trackSignupCompletedAfterRegistration emits SignupCompleted', () {
    trackSignupCompletedAfterRegistration(testWidgetRef());
    expect(fake.events.single, isA<SignupCompleted>());
  });

  test('trackClientStatementShared emits StatementShared', () {
    trackClientStatementShared(testWidgetRef());
    expect(fake.events.single, isA<StatementShared>());
  });
}

class _ContainerRef implements Ref {
  _ContainerRef(this._container);

  final ProviderContainer _container;

  @override
  T read<T>(ProviderListenable<T> provider) => _container.read(provider);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestWidgetRef extends _ContainerRef implements WidgetRef {
  _TestWidgetRef(super._container);
}