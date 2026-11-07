import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../prefs/app_settings_store.dart';

/// Bootstrap snapshot from [main] after disk load (or defaults when prefs unavailable).
final appSettingsBootstrapProvider = Provider<AppSettingsSnapshot>(
  (ref) => throw StateError('appSettingsBootstrapProvider must be overridden in main'),
);

final settingsPersistenceAvailableProvider = Provider<bool>(
  (ref) => ref.watch(appSettingsBootstrapProvider).persistenceAvailable,
);

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

final localeProvider = NotifierProvider<LocaleSettingsNotifier, Locale>(LocaleSettingsNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.read(appSettingsBootstrapProvider).themeMode;

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = ref.read(appSettingsBootstrapProvider).prefs;
    await AppSettingsStore.writeThemeMode(prefs, mode);
  }
}

class LocaleSettingsNotifier extends Notifier<Locale> {
  @override
  Locale build() => ref.read(appSettingsBootstrapProvider).locale;

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = ref.read(appSettingsBootstrapProvider).prefs;
    await AppSettingsStore.writeLocale(prefs, locale);
  }
}
