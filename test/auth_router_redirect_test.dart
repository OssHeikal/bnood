import 'package:bnood/app/bnood_app.dart';
import 'package:bnood/app/app_splash_session.dart';
import 'package:bnood/app/router.dart';
import 'package:bnood/core/prefs/app_settings_store.dart';
import 'package:bnood/core/providers/settings_provider.dart';
import 'package:bnood/core/storage/session_store.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_paths.dart';
import 'package:bnood/features/auth/complete_profile_screen.dart';
import 'package:bnood/features/auth/login_screen.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/app/shell_scaffold.dart';
import 'package:bnood/features/home/home_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';

AppSettingsSnapshot _bootstrap() =>
    const AppSettingsSnapshot(themeMode: ThemeMode.light, locale: Locale('en'), prefs: null);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(AppSplashSession.resetForTest);

  testWidgets('authenticated user stays on shell home tab', (tester) async {
    AppSplashSession.completed = true;
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(_bootstrap()),
          sessionStoreProvider.overrideWithValue(FakeSessionStore()),
        ],
        child: const BnoodApp(),
      ),
    );
    final element = tester.element(find.byType(BnoodApp));
    container = ProviderScope.containerOf(element);
    container.read(authControllerProvider.notifier).adoptSessionForTest(
          const User(id: 'usr', phone: '+201012345678', name: 'Eng'),
        );
    await tester.pump();
    container.read(goRouterProvider).go('/home');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(ShellScaffold), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    final l10n = AppLocalizations.of(tester.element(find.byType(ShellScaffold)));
    expect(find.text(l10n.shellTabNotOnlineTitle), findsNothing);
  });

  testWidgets('incomplete name redirects to complete profile', (tester) async {
    AppSplashSession.completed = true;
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(_bootstrap()),
          sessionStoreProvider.overrideWithValue(FakeSessionStore()),
        ],
        child: const BnoodApp(),
      ),
    );
    final element = tester.element(find.byType(BnoodApp));
    container = ProviderScope.containerOf(element);
    container.read(authControllerProvider.notifier).adoptSessionForTest(
          const User(id: 'usr', phone: '+201012345678'),
        );
    await tester.pump();
    container.read(goRouterProvider).go(AuthPaths.remote);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(CompleteProfileScreen), findsOneWidget);
    expect(find.byType(ShellScaffold), findsNothing);
  });

  testWidgets('unauthenticated user cannot open local home', (tester) async {
    AppSplashSession.completed = true;
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(_bootstrap()),
          sessionStoreProvider.overrideWithValue(FakeSessionStore()),
        ],
        child: const BnoodApp(),
      ),
    );
    final element = tester.element(find.byType(BnoodApp));
    container = ProviderScope.containerOf(element);
    await tester.pump();
    container.read(goRouterProvider).go('/home');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(HomeScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
