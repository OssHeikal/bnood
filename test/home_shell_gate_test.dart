import 'package:bnood/app/app_shell_online_tabs.dart';
import 'package:bnood/app/app_shell_tab_gate.dart';
import 'package:bnood/core/api/home_api.dart';
import 'package:bnood/core/home/app_home_dashboard.dart';
import 'package:bnood/core/home/app_home_totals.dart';
import 'package:bnood/core/clients/clients_providers.dart';
import 'package:bnood/core/home/home_riverpod.dart';
import 'package:bnood/core/home/home_repository.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/home/home_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';

class CountingHomeRepository extends HomeRepository {
  CountingHomeRepository() : super(HomeApi(sessionStore: FakeSessionStore(token: 'tok')));

  static var dashboardLoads = 0;

  @override
  Future<AppHomeDashboard> getHomeDashboard() async {
    dashboardLoads++;
    return const AppHomeDashboard(
      totals: AppHomeTotals(receivedMinor: 0, spentMinor: 0, remainingMinor: 0),
      clients: [],
      craftsmen: [],
      suppliers: [],
    );
  }
}

class _AuthComplete extends AuthController {
  @override
  AuthState build() {
    return const AuthState(
      bootstrapStatus: AuthBootstrapStatus.authenticated,
      user: User(id: 'u', phone: '+2010', name: 'Osama'),
      bootstrapStarted: true,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    CountingHomeRepository.dashboardLoads = 0;
  });

  testWidgets('remote signed-in home tab mounts HomeScreen and loads dashboard', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_AuthComplete.new),
          remoteClientsEnabledProvider.overrideWithValue(true),
          homeRepositoryProvider.overrideWithValue(CountingHomeRepository()),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AppShellTabGate(
            tab: AppShellTabId.home,
            child: HomeScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('غير متاح على الإنترنت بعد'), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Osama'), findsOneWidget);
    expect(CountingHomeRepository.dashboardLoads, greaterThanOrEqualTo(1));
  });
}
