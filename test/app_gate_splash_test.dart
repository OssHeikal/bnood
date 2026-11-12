import 'package:bnood/app/app_splash_session.dart';
import 'package:bnood/app/app_startup_splash.dart';
import 'package:bnood/app/bnood_app.dart';
import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/core/app_gate/app_config_record.dart';
import 'package:bnood/core/prefs/app_settings_store.dart';
import 'package:bnood/core/providers/settings_provider.dart';
import 'package:bnood/core/storage/session_store.dart';
import 'package:bnood/features/app_gate/app_gate_cold_start.dart';
import 'package:bnood/features/app_gate/app_gate_provider.dart';
import 'package:bnood/features/app_gate/app_gate_session.dart';
import 'package:bnood/features/app_gate/app_optional_update_screen.dart';
import 'package:bnood/features/auth/auth_paths.dart';
import 'package:bnood/features/auth/login_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_app_gate_notifier.dart';
import 'support/fake_session_store.dart';
import 'support/stub_app_config_api.dart';

AppSettingsSnapshot _bootstrap() =>
    const AppSettingsSnapshot(themeMode: ThemeMode.light, locale: Locale('en'), prefs: null);

AppConfigData _configJson(String status) => AppConfigData.fromDataJson({
      'status': status,
      'message': '',
      'store_url': 'https://example.com/store',
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    AppSplashSession.resetForTest();
    AppGateSession.resetForTest();
    AppGateColdStart.resetForTest();
  });

  testWidgets('config 5xx fail-open continues to login', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(_bootstrap()),
          sessionStoreProvider.overrideWithValue(FakeSessionStore()),
          appConfigApiProvider.overrideWith(
            (ref) => StubAppConfigApi(({
              required platform,
              required version,
              required locale,
            }) async {
              throw AuthApiException(statusCode: 503, message: 'down');
            }),
          ),
        ],
        child: const BnoodApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 15));
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(AppOptionalUpdateScreen), findsNothing);
  });

  testWidgets('optional update Later lands on login', (tester) async {
    final optional = _configJson('optional_update');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(_bootstrap()),
          sessionStoreProvider.overrideWithValue(FakeSessionStore()),
          appGateProvider.overrideWith(() => FakeAppGateNotifier(optional)),
        ],
        child: const BnoodApp(),
      ),
    );
    expect(find.byType(AppStartupSplashPage), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 15));
    expect(find.byType(AppOptionalUpdateScreen), findsOneWidget);
    final l10n = AppLocalizations.of(tester.element(find.byType(AppOptionalUpdateScreen)));
    await tester.tap(find.text(l10n.gateLaterAction));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(AppGateSession.postSplashDestination, AuthPaths.login);
  });
}
