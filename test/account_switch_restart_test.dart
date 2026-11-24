import 'package:bnood/app/router.dart';
import 'package:bnood/core/account/account_context_providers.dart';
import 'package:bnood/core/account/auth_office_payload.dart';
import 'package:bnood/core/account/office_membership.dart';
import 'package:bnood/core/app_state/settings_provider.dart';
import 'package:bnood/core/data/prefs/app_settings_store.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/home/data/home_row_models.dart';
import 'package:bnood/features/home/presentation/providers/home_dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:bnood/features/home/data/app_home_dashboard.dart';
import 'package:bnood/features/home/data/app_home_totals.dart';
import 'package:bnood/features/home/data/home_api.dart';
import 'package:bnood/features/home/data/home_riverpod.dart';
import 'package:bnood/features/home/data/home_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_session_store.dart';
import 'support/home_notifier_stubs.dart';

const _officeId = '01J9Z8XQ8K9M2N3P4R5S6T7V8W';

class _StubHomeRepository extends HomeRepository {
  _StubHomeRepository() : super(HomeApi(sessionStore: FakeSessionStore()));

  @override
  Future<AppHomeDashboard> getHomeDashboard() async {
    return AppHomeDashboard(
      totals: AppHomeTotals(
        receivedMinor: 0,
        spentMinor: 0,
        remainingMinor: 0,
      ),
      clients: const [],
      craftsmen: const [],
      suppliers: const [],
    );
  }
}

List<Override> _homeDashboardStubs({bool stubTotals = true}) => [
  homeRepositoryProvider.overrideWithValue(_StubHomeRepository()),
  if (stubTotals)
    homeTotalsOverride(const HomeTotals(receivedPiastres: 0, spentPiastres: 0)),
  homeActiveProjectsOverride(const []),
  emptyHomeSupplierSpendsOverride(),
  emptyHomeCraftsmenOverride(),
  emptyHomeSuppliersOverride(),
];

class _SequencedHomeTotals extends HomeTotalsNotifier {
  _SequencedHomeTotals(this._values);

  final List<HomeTotals> _values;
  var _index = 0;

  @override
  Future<HomeTotals> fetch() async {
    final value = _values[_index.clamp(0, _values.length - 1)];
    if (_index < _values.length - 1) {
      _index++;
    }
    return value;
  }
}

class _AuthMember extends AuthController {
  @override
  AuthState build() {
    return const AuthState(
      bootstrapStatus: AuthBootstrapStatus.authenticated,
      user: User(id: 'u1', phone: '01000000001', name: 'Member'),
      officeContext: AuthOfficePayload(
        offices: [
          OfficeMembership(
            id: _officeId,
            name: 'Office A',
            readOnly: false,
            isOwner: false,
          ),
        ],
      ),
    );
  }
}

GoRouter _testRouter() {
  return GoRouter(
    initialLocation: accountShellHomePath,
    routes: [
      GoRoute(
        path: accountShellHomePath,
        builder: (_, _) => const SizedBox(key: Key('home')),
      ),
      GoRoute(
        path: '/projects',
        builder: (_, _) => const SizedBox(key: Key('projects')),
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    debugAccountScopedResetHook = null;
    ApiOfficeHeader.syncOfficeId(null);
  });

  ProviderContainer newContainer({GoRouter? router}) {
    SharedPreferences.setMockInitialValues({});
    final testRouter = router ?? _testRouter();
    return ProviderContainer(
      overrides: [
        goRouterProvider.overrideWithValue(testRouter),
        appSettingsBootstrapProvider.overrideWithValue(
          const AppSettingsSnapshot(
            prefs: null,
            themeMode: ThemeMode.system,
            locale: Locale('ar'),
          ),
        ),
        authControllerProvider.overrideWith(_AuthMember.new),
        ..._homeDashboardStubs(stubTotals: false),
        homeTotalsProvider.overrideWith(
          () => _SequencedHomeTotals([
            const HomeTotals(receivedPiastres: 100, spentPiastres: 10),
            const HomeTotals(receivedPiastres: 200, spentPiastres: 20),
          ]),
        ),
      ],
    );
  }

  test('account switch bumps epoch and requests home route', () async {
    final router = _testRouter();
    addTearDown(router.dispose);
    final container = newContainer(router: router);
    addTearDown(container.dispose);
    container.read(accountContextLifecycleProvider);
    await pumpEventQueue();

    router.go('/projects');

    await container
        .read(accountContextProvider.notifier)
        .selectOffice(_officeId);
    await pumpEventQueue();

    expect(container.read(appLedgerScopeEpochProvider), 1);
    expect(router.routeInformationProvider.value.uri.path, accountShellHomePath);
    expect(ApiOfficeHeader.headerValue(), _officeId);
  });

  test('account switch reloads cached providers for new account', () async {
    var resets = 0;
    debugAccountScopedResetHook = () => resets++;

    final router = _testRouter();
    addTearDown(router.dispose);
    final container = newContainer(router: router);
    addTearDown(container.dispose);
    container.read(accountContextLifecycleProvider);
    await pumpEventQueue();

    await container.read(homeTotalsProvider.future);
    expect(container.read(homeTotalsProvider).value?.receivedPiastres, 100);

    await container
        .read(accountContextProvider.notifier)
        .selectOffice(_officeId);
    await pumpEventQueue();

    expect(resets, 1);
    await container.read(homeTotalsProvider.future);
    expect(container.read(homeTotalsProvider).value?.receivedPiastres, 200);
  });

  test('selecting the same account does not restart', () async {
    var resets = 0;
    debugAccountScopedResetHook = () => resets++;

    final router = _testRouter();
    addTearDown(router.dispose);
    final container = newContainer(router: router);
    addTearDown(container.dispose);
    container.read(accountContextLifecycleProvider);
    await pumpEventQueue();

    await container
        .read(accountContextProvider.notifier)
        .selectOffice(_officeId);
    await pumpEventQueue();
    resets = 0;

    await container
        .read(accountContextProvider.notifier)
        .selectOffice(_officeId);
    await pumpEventQueue();

    expect(resets, 0);
    expect(container.read(appLedgerScopeEpochProvider), 1);
  });
}