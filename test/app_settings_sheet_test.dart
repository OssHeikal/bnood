import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/prefs/app_settings_store.dart';
import 'package:bnood/core/providers/settings_provider.dart';
import 'package:bnood/app/widgets/shell_nav_icon.dart';
import 'package:bnood/features/settings/app_settings_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
        overrides: [appSettingsBootstrapProvider.overrideWithValue(bootstrap)],
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

  testWidgets('Arabic labels and العربية language option', (tester) async {
    await pumpSheet(tester);
    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.text('المظهر'), findsOneWidget);
    expect(find.text('اللغة'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('بنود'), findsNothing);
    expect(find.byType(SegmentedButton<dynamic>), findsNothing);
  });

  testWidgets('English UI uses localized theme labels', (tester) async {
    await pumpSheet(tester, locale: const Locale('en'));
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
  });

  testWidgets('tap updates theme and locale providers', (tester) async {
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
              return const Scaffold(body: AppSettingsSheet());
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

  testWidgets('language rows have no leading icons', (tester) async {
    await pumpSheet(tester);
    expect(find.byType(ShellNavIcon), findsNWidgets(2));
  });

  testWidgets('large text scale lays out in scrollable sheet', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 520));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final bootstrap = await testBootstrap();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appSettingsBootstrapProvider.overrideWithValue(bootstrap)],
        child: MaterialApp(
          theme: AppFoundationTheme.dark(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.35)),
            child: const Scaffold(body: AppSettingsSheet()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
