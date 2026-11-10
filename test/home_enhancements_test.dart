import 'package:bnood/core/clients/clients_providers.dart';
import 'package:bnood/core/subscription/app_subscription.dart';
import 'package:bnood/core/subscription/subscription_riverpod.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/core/money/remote_money_units.dart';
import 'package:bnood/core/providers/dashboard_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_paths.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/home/home_screen.dart';
import 'package:bnood/features/home/widgets/home_identity_title.dart';
import 'package:bnood/features/providers/widgets/remote_craftsman_summary_card.dart';
import 'package:bnood/core/prefs/app_settings_store.dart';
import 'package:bnood/core/providers/settings_provider.dart';
import 'package:bnood/features/settings/app_settings_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/home_notifier_stubs.dart';

class _SilentSubscriptionNotifier extends SubscriptionNotifier {
  @override
  Future<AppSubscriptionSnapshot?> build() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderScope remoteHomeScope({required Widget child, List<Override> extra = const []}) {
    final now = DateTime.utc(2026, 11, 1);
    return ProviderScope(
      overrides: [
        remoteClientsEnabledProvider.overrideWithValue(true),
        authControllerProvider.overrideWith(_AuthOsama.new),
        homeTotalsOverride(const HomeTotals(receivedPiastres: 0, spentPiastres: 0)),
        homeClientBalancesOverride(const []),
        homeCraftsmenProvider.overrideWith(
          () => StubHomeCraftsmenNotifier([
            HomeCraftsmanActivityRow(
              craftsman: CraftsmenData(
                id: 'p1',
                workspaceId: 'remote',
                name: 'أحمد السباك',
                phone: '',
                createdAt: now,
                updatedAt: now,
              ),
              paidPiastres: 2_000_000,
              lastLaborAt: now,
              remainingPiastres: null,
              clientsCount: 3,
            ),
          ]),
        ),
        emptyHomeSupplierSpendsOverride(),
        subscriptionProvider.overrideWith(_SilentSubscriptionNotifier.new),
        ...extra,
      ],
      child: child,
    );
  }

  testWidgets('remote home uses identity app bar and craftsman linked clients', (tester) async {
    await tester.pumpWidget(
      remoteHomeScope(
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeIdentityTitle), findsOneWidget);
    expect(find.text('Osama Engineer'), findsOneWidget);
    expect(find.text('3 عملاء مرتبطين'), findsOneWidget);
    expect(find.byType(RemoteCraftsmanSummaryCard), findsOneWidget);
    expect(find.text('Paid'), findsNothing);
  });

  testWidgets('avatar opens profile screen', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
        GoRoute(path: AuthPaths.profile, builder: (_, _) => const Scaffold(body: Text('profile-body'))),
      ],
    );

    await tester.pumpWidget(
      remoteHomeScope(
        child: MaterialApp.router(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('OE'));
    await tester.pumpAndSettle();
    expect(find.text('profile-body'), findsOneWidget);
  });

  testWidgets('settings opens full screen not sheet', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final bootstrap = AppSettingsSnapshot(
      themeMode: ThemeMode.system,
      locale: const Locale('en'),
      prefs: prefs,
    );

    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
        GoRoute(path: AuthPaths.settings, builder: (_, _) => const AppSettingsScreen()),
      ],
    );

    await tester.pumpWidget(
      remoteHomeScope(
        extra: [appSettingsBootstrapProvider.overrideWithValue(bootstrap)],
        child: MaterialApp.router(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    expect(find.byType(AppSettingsScreen), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('home list bottom padding respects shell clearance', (tester) async {
    const clearance = 112.0;
    await tester.pumpWidget(
      remoteHomeScope(
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(padding: EdgeInsets.only(bottom: clearance)),
            child: const HomeScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final list = tester.widget<ListView>(find.byType(ListView));
    final padding = list.padding as EdgeInsets?;
    expect(padding?.bottom, greaterThanOrEqualTo(clearance));
  });

  testWidgets('greeting uses morning before noon Cairo', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionProvider.overrideWith(_SilentSubscriptionNotifier.new),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeFoundationScope(
            child: Scaffold(
              appBar: AppBar(
                title: HomeIdentityTitle(
                  displayName: 'Tester',
                  cairoNowOverride: DateTime(2026, 11, 9, 9, 0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Good morning'), findsOneWidget);
  });
}

class _AuthOsama extends AuthController {
  @override
  AuthState build() => AuthState(
        bootstrapStatus: AuthBootstrapStatus.authenticated,
        user: User(
          id: 'u1',
          phone: '+201012345678',
          name: 'Osama Engineer',
          phoneVerifiedAt: DateTime.utc(2026, 1, 1),
        ),
        bootstrapStarted: true,
      );
}
