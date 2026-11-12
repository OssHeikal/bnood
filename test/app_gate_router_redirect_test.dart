import 'package:bnood/app/app_splash_session.dart';
import 'package:bnood/app/bnood_app.dart';
import 'package:bnood/app/router.dart';
import 'package:bnood/core/content/content_page_record.dart' show ContentPage, ContentPaths;
import 'package:bnood/core/prefs/app_settings_store.dart';
import 'package:bnood/core/providers/settings_provider.dart';
import 'package:bnood/core/storage/session_store.dart';
import 'package:bnood/features/app_gate/app_maintenance_screen.dart';
import 'package:bnood/features/auth/auth_paths.dart';
import 'package:bnood/features/auth/login_screen.dart';
import 'package:bnood/features/app_gate/app_gate_provider.dart';
import 'package:bnood/features/content/content_page_provider.dart';
import 'package:bnood/features/content/content_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_app_gate_notifier.dart';
import 'support/fake_session_store.dart';
import 'support/stub_pages_api.dart';
import 'package:bnood/core/app_gate/app_config_record.dart';

AppSettingsSnapshot _bootstrap() =>
    const AppSettingsSnapshot(themeMode: ThemeMode.light, locale: Locale('en'), prefs: null);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    AppSplashSession.resetForTest();
  });

  testWidgets('logged-out user can open public content page', (tester) async {
    AppSplashSession.completed = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(_bootstrap()),
          sessionStoreProvider.overrideWithValue(FakeSessionStore()),
          appGateProvider.overrideWith(() => FakeAppGateNotifier(AppConfigData.failOpen())),
          pagesApiProvider.overrideWith(
            (ref) => StubPagesApi(({required slug, required locale}) async {
              return ContentPage.fromDataJson({
                'slug': slug,
                'locale': locale,
                'title': 'Terms',
                'body': '<p>Terms</p>',
                'format': 'html',
                'updated_at': '2025-01-01T00:00:00Z',
              });
            }),
          ),
        ],
        child: const BnoodApp(),
      ),
    );
    await tester.pump();
    final element = tester.element(find.byType(BnoodApp));
    final container = ProviderScope.containerOf(element);
    container.read(goRouterProvider).go(ContentPaths.terms);
    await tester.pumpAndSettle();
    expect(find.byType(ContentPageScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('maintenance gate is exempt from auth redirect', (tester) async {
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
    await tester.pump();
    final element = tester.element(find.byType(BnoodApp));
    final container = ProviderScope.containerOf(element);
    container.read(goRouterProvider).go('/gate/maintenance');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AppMaintenanceScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('unauthenticated user on login stays on login', (tester) async {
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
    await tester.pump();
    final element = tester.element(find.byType(BnoodApp));
    final container = ProviderScope.containerOf(element);
    container.read(goRouterProvider).go(AuthPaths.login);
    await tester.pump();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
