import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/prefs/app_settings_store.dart';
import 'package:bnood/core/providers/settings_provider.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/settings/app_preferences_body.dart';
import 'package:bnood/features/settings/app_settings_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _AuthUser extends AuthController {
  @override
  AuthState build() => AuthState(
        bootstrapStatus: AuthBootstrapStatus.authenticated,
        user: const User(id: 'u1', phone: '+201012345678', name: 'Tester'),
        bootstrapStarted: true,
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppSettingsSnapshot> testBootstrap() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return AppSettingsSnapshot(
      themeMode: ThemeMode.system,
      locale: const Locale('ar'),
      prefs: prefs,
    );
  }

  Future<void> pumpSheet(
    WidgetTester tester, {
    Locale locale = const Locale('ar'),
    Brightness brightness = Brightness.light,
    Size surface = const Size(390, 640),
  }) async {
    await tester.binding.setSurfaceSize(surface);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final bootstrap = await testBootstrap();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(bootstrap),
          authControllerProvider.overrideWith(_AuthUser.new),
        ],
        child: MaterialApp(
          theme: brightness == Brightness.dark ? AppFoundationTheme.dark() : AppFoundationTheme.light(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: AppSettingsSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sheet shows menu hub not theme controls', (tester) async {
    await pumpSheet(tester);
    expect(find.text('الحساب'), findsOneWidget);
    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.text('المظهر'), findsNothing);
  });

  testWidgets('preferences body Arabic labels', (tester) async {
    final bootstrap = await testBootstrap();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appSettingsBootstrapProvider.overrideWithValue(bootstrap)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: AppPreferencesBody()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('المظهر'), findsOneWidget);
    expect(find.text('اللغة'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
  });

  testWidgets('tap updates theme and locale on preferences body', (tester) async {
    late ThemeMode themeMode;
    late Locale locale;

    final bootstrap = await testBootstrap();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appSettingsBootstrapProvider.overrideWithValue(bootstrap)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer(
            builder: (context, ref, _) {
              themeMode = ref.watch(themeModeProvider);
              locale = ref.watch(localeProvider);
              return const Scaffold(body: AppPreferencesBody());
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(themeMode, ThemeMode.system);
    await tester.tap(find.text('داكن'));
    await tester.pumpAndSettle();
    expect(themeMode, ThemeMode.dark);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(locale, const Locale('en'));
  });

  testWidgets('fits constrained height without overflow', (tester) async {
    await pumpSheet(tester, surface: const Size(390, 400), brightness: Brightness.dark);
    expect(tester.takeException(), isNull);
  });
}
