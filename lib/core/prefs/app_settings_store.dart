import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bnood_prefs_access.dart';

class AppSettingsSnapshot {
  const AppSettingsSnapshot({
    required this.themeMode,
    required this.locale,
    this.prefs,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final SharedPreferences? prefs;

  bool get persistenceAvailable => prefs != null;

  static const defaults = AppSettingsSnapshot(
    themeMode: ThemeMode.system,
    locale: Locale('ar'),
  );
}

abstract final class AppSettingsStore {
  static const themeKey = 'app_theme_mode';
  static const localeKey = 'app_locale_code';

  static Future<AppSettingsSnapshot> load() async {
    final prefs = await BnoodPrefsAccess.getInstance();
    if (prefs == null) {
      return AppSettingsSnapshot.defaults;
    }
    return AppSettingsSnapshot(
      themeMode: readThemeMode(prefs) ?? ThemeMode.system,
      locale: readLocale(prefs) ?? const Locale('ar'),
      prefs: prefs,
    );
  }

  static ThemeMode? readThemeMode(SharedPreferences prefs) {
    final raw = prefs.getString(themeKey);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }

  static Locale? readLocale(SharedPreferences prefs) {
    final raw = prefs.getString(localeKey);
    return switch (raw) {
      'ar' => const Locale('ar'),
      'en' => const Locale('en'),
      _ => null,
    };
  }

  static Future<bool> writeThemeMode(SharedPreferences? prefs, ThemeMode mode) async {
    if (prefs == null) return false;
    return prefs.setString(themeKey, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }

  static Future<bool> writeLocale(SharedPreferences? prefs, Locale locale) async {
    if (prefs == null) return false;
    final code = locale.languageCode;
    if (code != 'ar' && code != 'en') return false;
    return prefs.setString(localeKey, code);
  }
}
