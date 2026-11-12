import 'package:bnood/app/bnood_app.dart';
import 'package:bnood/app/app_splash_session.dart';
import 'package:bnood/app/router.dart';
import 'package:bnood/app/shell_scaffold.dart';
import 'package:bnood/core/prefs/app_settings_store.dart';
import 'package:bnood/core/providers/settings_provider.dart';
import 'package:bnood/core/storage/session_store.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/clients/clients_list_screen.dart';
import 'package:bnood/features/items/items_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';

AppSettingsSnapshot _bootstrap() =>
    const AppSettingsSnapshot(themeMode: ThemeMode.light, locale: Locale('en'), prefs: null);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(AppSplashSession.resetForTest);

  testWidgets('clients tab loads list for remote session', (tester) async {
    AppSplashSession.completed = true;
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
    final container = ProviderScope.containerOf(element);
    container.read(authControllerProvider.notifier).adoptSessionForTest(
          const User(id: 'usr', phone: '+201012345678', name: 'Eng'),
        );
    await tester.pump();
    container.read(goRouterProvider).go('/clients');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(ShellScaffold), findsOneWidget);
    expect(find.byType(ClientsListScreen), findsOneWidget);
  });

  testWidgets('items tab loads catalog for remote session', (tester) async {
    AppSplashSession.completed = true;
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
    final container = ProviderScope.containerOf(element);
    container.read(authControllerProvider.notifier).adoptSessionForTest(
          const User(id: 'usr', phone: '+201012345678', name: 'Eng'),
        );
    await tester.pump();
    container.read(goRouterProvider).go('/items');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(ShellScaffold), findsOneWidget);
    expect(find.byType(ItemsScreen), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 20)));
}
