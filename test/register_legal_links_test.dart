import 'package:bnood/app/app_splash_session.dart';
import 'package:bnood/app/bnood_app.dart';
import 'package:bnood/app/router.dart';
import 'package:bnood/core/prefs/app_settings_store.dart';
import 'package:bnood/core/providers/settings_provider.dart';
import 'package:bnood/core/storage/session_store.dart';
import 'package:bnood/features/auth/auth_paths.dart';
import 'package:bnood/features/auth/register_screen.dart';
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

  testWidgets('register shows terms and privacy links', (tester) async {
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
    final container = ProviderScope.containerOf(tester.element(find.byType(BnoodApp)));
    container.read(goRouterProvider).go(AuthPaths.register);
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(RegisterScreen)));
    expect(find.textContaining(l10n.settingsContentTerms), findsOneWidget);
    expect(find.textContaining(l10n.settingsContentPrivacy), findsOneWidget);
  });
}
