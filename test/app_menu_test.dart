import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/prefs/app_settings_store.dart';
import 'package:bnood/core/providers/settings_provider.dart';
import 'package:bnood/core/subscription/app_subscription.dart';
import 'package:bnood/core/subscription/subscription_riverpod.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_paths.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/settings/app_menu_body.dart';
import 'package:bnood/features/settings/app_preferences_body.dart';
import 'package:bnood/features/settings/app_preferences_screen.dart';
import 'package:bnood/features/settings/app_settings_screen.dart';
import 'package:bnood/features/subscription/paywall_launcher.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AuthUser extends AuthController {
  @override
  AuthState build() => AuthState(
        bootstrapStatus: AuthBootstrapStatus.authenticated,
        user: const User(id: 'u1', phone: '+201012345678', name: 'Tester'),
        bootstrapStarted: true,
      );
}

class _EnabledSubscription extends SubscriptionNotifier {
  @override
  Future<AppSubscriptionSnapshot?> build() async => AppSubscriptionSnapshot.fromDataJson({
        'paywall_enabled': true,
        'entitlements': {'show_paywall_surfaces': true},
      });
}

class _DisabledSubscription extends SubscriptionNotifier {
  @override
  Future<AppSubscriptionSnapshot?> build() async => AppSubscriptionSnapshot.fromDataJson({
        'paywall_enabled': false,
        'entitlements': {'show_paywall_surfaces': true},
      });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppSettingsSnapshot> bootstrap() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return AppSettingsSnapshot(themeMode: ThemeMode.system, locale: const Locale('en'), prefs: prefs);
  }

  testWidgets('menu lists account subscription settings then content in order when signed in', (tester) async {
    final snap = await bootstrap();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(snap),
          authControllerProvider.overrideWith(_AuthUser.new),
          subscriptionProvider.overrideWith(_EnabledSubscription.new),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: AppMenuBody()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(AppMenuBody)));
    final labels = find.byType(Text).evaluate().map((e) => (e.widget as Text).data).whereType<String>().toList();
    final accountIndex = labels.indexOf(l10n.authAccountSection);
    final subscriptionIndex = labels.indexOf(l10n.profileSubscriptionSection);
    final settingsIndex = labels.indexOf(l10n.settingsTitle);
    final aboutIndex = labels.indexOf(l10n.settingsContentAbout);
    expect(accountIndex, greaterThanOrEqualTo(0));
    expect(subscriptionIndex, greaterThan(accountIndex));
    expect(settingsIndex, greaterThan(subscriptionIndex));
    expect(aboutIndex, greaterThan(settingsIndex));
  });

  testWidgets('subscription row hidden when signed out', (tester) async {
    final snap = await bootstrap();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appSettingsBootstrapProvider.overrideWithValue(snap)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: AppMenuBody()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Subscription'), findsNothing);
  });

  testWidgets('subscription row hidden when subscription is disabled', (tester) async {
    final snap = await bootstrap();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(snap),
          authControllerProvider.overrideWith(_AuthUser.new),
          subscriptionProvider.overrideWith(_DisabledSubscription.new),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: AppMenuBody()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Subscription'), findsNothing);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('tapping subscription invokes paywall launcher', (tester) async {
    var paywallCalls = 0;
    final snap = await bootstrap();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(snap),
          authControllerProvider.overrideWith(_AuthUser.new),
          subscriptionProvider.overrideWith(_EnabledSubscription.new),
          paywallPresentProvider.overrideWith(
            (ref) => (context, [refArg]) async {
              paywallCalls++;
            },
          ),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: AppMenuBody()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Subscription'));
    await tester.pump();
    expect(paywallCalls, 1);
  });

  testWidgets('preferences sub-screen shows theme and language only', (tester) async {
    final snap = await bootstrap();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appSettingsBootstrapProvider.overrideWithValue(snap)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AppPreferencesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(AppPreferencesScreen)));
    expect(find.text(l10n.settingsThemeSection), findsOneWidget);
    expect(find.text(l10n.settingsLanguageSection), findsOneWidget);
    expect(find.text(l10n.settingsContentAbout), findsNothing);
    expect(find.text(l10n.authSignOut), findsNothing);
  });

  testWidgets('logout confirm still works from menu', (tester) async {
    final snap = await bootstrap();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(snap),
          authControllerProvider.overrideWith(_AuthUser.new),
          subscriptionProvider.overrideWith(_DisabledSubscription.new),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AppMenuScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign out?'), findsOneWidget);
  });

  testWidgets('menu settings row opens preferences route', (tester) async {
    final snap = await bootstrap();
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Scaffold(body: AppMenuBody())),
        GoRoute(path: AuthPaths.preferences, builder: (_, _) => const AppPreferencesScreen()),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(snap),
          authControllerProvider.overrideWith(_AuthUser.new),
          subscriptionProvider.overrideWith(_DisabledSubscription.new),
        ],
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
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(AppPreferencesScreen), findsOneWidget);
  });
}
