import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Foundation theme for preview and new widgets. Production [BnoodApp] keeps legacy theme unchanged.
abstract final class AppFoundationTheme {
  static ThemeData light() => _build(Brightness.light, AppColors.light);

  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final text = AppText.fromColors(colors);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.canvas,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.primaryDark,
        onSecondary: colors.onPrimary,
        error: colors.error,
        onError: colors.onError,
        surface: colors.surface,
        onSurface: colors.onSurface,
      ),
      extensions: [colors, text],
      dividerColor: colors.outline,
    );
  }
}
