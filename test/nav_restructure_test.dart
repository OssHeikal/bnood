import 'package:bnood/app/bnood_app.dart';
import 'package:bnood/app/app_splash_session.dart';
import 'package:bnood/app/router.dart';
import 'package:bnood/app/widgets/shell_notifications_action.dart';
import 'package:bnood/core/app_state/settings_provider.dart';
import 'package:bnood/core/data/prefs/app_settings_store.dart';
import 'package:bnood/core/data/storage/session_store.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_paths.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/core/shared/pagination/paged_fetch_page.dart';
import 'package:bnood/features/notifications/presentation/providers/notifications_inbox_paging.dart';
import 'package:bnood/features/notifications/presentation/providers/notifications_unread_provider.dart';
import 'package:bnood/features/notifications/presentation/screens/notifications_inbox_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(AppSplashSession.resetForTest);

  const bootstrap = AppSettingsSnapshot(
    themeMode: ThemeMode.light,
    locale: Locale('en'),
    prefs: null,
  );

  Future<ProviderContainer> pumpBnood(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(bootstrap),
          sessionStoreProvider.overrideWithValue(FakeSessionStore()),
          notificationsInboxPageFetcherProvider.overrideWith(
            (ref) => ({required int page, required int pageSize}) async {
              return const PagedFetchPage(items: [], hasMore: false);
            },
          ),
          notificationsUnreadCountProvider.overrideWith((ref) async => 0),
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
    return container;
  }

  testWidgets('/settings redirects to /more shell tab', (tester) async {
    AppSplashSession.completed = true;
    final container = await pumpBnood(tester);
    container.read(goRouterProvider).go(AuthPaths.settings);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(container.read(goRouterProvider).state.matchedLocation, '/more');
  });

  testWidgets('home shows notifications action only on home tab', (tester) async {
    AppSplashSession.completed = true;
    final container = await pumpBnood(tester);
    container.read(goRouterProvider).go('/home');
    await tester.pumpAndSettle();
    expect(find.byType(ShellNotificationsAction), findsOneWidget);

    container.read(goRouterProvider).go('/projects');
    await tester.pumpAndSettle();
    expect(find.byType(ShellNotificationsAction), findsNothing);
  });

  testWidgets('notifications inbox opens from home', (tester) async {
    AppSplashSession.completed = true;
    final container = await pumpBnood(tester);
    container.read(goRouterProvider).go('/home');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ShellNotificationsAction));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      container.read(goRouterProvider).state.matchedLocation,
      NotificationsInboxScreen.path,
    );
  });
}