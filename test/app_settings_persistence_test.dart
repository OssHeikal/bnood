import 'package:bnood/core/prefs/app_settings_store.dart';
import 'package:bnood/core/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppSettingsSnapshot> bootstrapWithEmptyStore() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return AppSettingsSnapshot(
      themeMode: ThemeMode.system,
      locale: const Locale('ar'),
      prefs: prefs,
    );
  }

  test('disk: each theme mode round-trips', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    for (final mode in ThemeMode.values) {
      await AppSettingsStore.writeThemeMode(prefs, mode);
      expect(AppSettingsStore.readThemeMode(prefs), mode);
    }
  });

  test('disk: locale round-trips ar and en', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await AppSettingsStore.writeLocale(prefs, const Locale('ar'));
    expect(AppSettingsStore.readLocale(prefs), const Locale('ar'));

    await AppSettingsStore.writeLocale(prefs, const Locale('en'));
    expect(AppSettingsStore.readLocale(prefs), const Locale('en'));
  });

  test('disk: invalid keys fall back on load', () async {
    SharedPreferences.setMockInitialValues({
      AppSettingsStore.themeKey: 'broken',
      AppSettingsStore.localeKey: 'xx',
    });
    final snap = await AppSettingsStore.load();
    expect(snap.themeMode, ThemeMode.system);
    expect(snap.locale, const Locale('ar'));
  });

  test('disk: load restores stored values', () async {
    SharedPreferences.setMockInitialValues({
      AppSettingsStore.themeKey: 'dark',
      AppSettingsStore.localeKey: 'en',
    });
    final snap = await AppSettingsStore.load();
    expect(snap.themeMode, ThemeMode.dark);
    expect(snap.locale, const Locale('en'));
  });

  test('notifier: setTheme persists for next load (in-memory mock store)', () async {
    final bootstrap = await bootstrapWithEmptyStore();
    final container = ProviderContainer(
      overrides: [appSettingsBootstrapProvider.overrideWithValue(bootstrap)],
    );
    addTearDown(container.dispose);

    await container.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
    expect(container.read(themeModeProvider), ThemeMode.dark);

    final prefs = bootstrap.prefs!;
    expect(AppSettingsStore.readThemeMode(prefs), ThemeMode.dark);

    final reloaded = await AppSettingsStore.load();
    expect(reloaded.themeMode, ThemeMode.dark);
  });

  test('notifier: rapid locale updates keep last value on disk', () async {
    final bootstrap = await bootstrapWithEmptyStore();
    final container = ProviderContainer(
      overrides: [appSettingsBootstrapProvider.overrideWithValue(bootstrap)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(localeProvider.notifier);
    await notifier.setLocale(const Locale('en'));
    await notifier.setLocale(const Locale('ar'));
    await notifier.setLocale(const Locale('en'));

    expect(AppSettingsStore.readLocale(bootstrap.prefs!), const Locale('en'));
  });

  test('write returns false when prefs null', () async {
    expect(await AppSettingsStore.writeThemeMode(null, ThemeMode.light), isFalse);
    expect(await AppSettingsStore.writeLocale(null, const Locale('ar')), isFalse);
  });
}
