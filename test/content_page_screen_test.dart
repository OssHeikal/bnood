import 'package:bnood/app/app_splash_session.dart';
import 'package:bnood/app/bnood_app.dart';
import 'package:bnood/app/router.dart';
import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/core/content/content_page_record.dart';
import 'package:bnood/core/prefs/app_settings_store.dart';
import 'package:bnood/core/providers/settings_provider.dart';
import 'package:bnood/core/storage/session_store.dart';
import 'package:bnood/features/content/content_page_provider.dart';
import 'package:bnood/features/content/content_page_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/stub_pages_api.dart';

AppSettingsSnapshot _bootstrap() =>
    const AppSettingsSnapshot(themeMode: ThemeMode.light, locale: Locale('en'), prefs: null);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(AppSplashSession.resetForTest);

  testWidgets('404 shows AppFallback copy', (tester) async {
    AppSplashSession.completed = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(_bootstrap()),
          sessionStoreProvider.overrideWithValue(FakeSessionStore()),
          pagesApiProvider.overrideWith(
            (ref) => StubPagesApi(({required slug, required locale}) async {
              throw AuthApiException(statusCode: 404, message: 'missing');
            }),
          ),
        ],
        child: const BnoodApp(),
      ),
    );
    await tester.pump();
    final container = ProviderScope.containerOf(tester.element(find.byType(BnoodApp)));
    container.read(goRouterProvider).go(ContentPaths.privacy);
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(ContentPageScreen)));
    expect(find.text(l10n.contentPageNotFoundTitle), findsOneWidget);
  });
}
