import 'package:bnood/app/bnood_app.dart';
import 'package:bnood/app/bnood_splash_session.dart';
import 'package:bnood/app/router.dart';
import 'package:bnood/core/prefs/app_settings_store.dart';
import 'package:bnood/core/providers/settings_provider.dart';
import 'package:bnood/core/storage/session_store.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/models/subscriber_user.dart';
import 'package:bnood/features/auth/remote_workspace_screen.dart';
import 'package:bnood/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';

AppSettingsSnapshot _bootstrap() =>
    const AppSettingsSnapshot(themeMode: ThemeMode.light, locale: Locale('en'), prefs: null);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(BnoodSplashSession.resetForTest);

  testWidgets('authenticated session redirects away from local home', (tester) async {
    BnoodSplashSession.completed = true;
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
          const SubscriberUser(id: 'usr', phone: '+201012345678'),
        );
    await tester.pump();
    container.read(goRouterProvider).go('/home');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(HomeScreen), findsNothing);
    expect(find.byType(RemoteWorkspaceScreen), findsOneWidget);
  });
}
