import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryDark,
        onSecondary: Colors.white,
        error: AppColors.danger,
        onError: Colors.white,
        surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        onSurface: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
      ),
      scaffoldBackgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
    );
    return base.copyWith(
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor:
            isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: AppColors.primary.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w700);
          }
          return TextStyle(
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted);
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.selected)) return Colors.white;
            return isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.selected)) return AppColors.primary;
            return isDark ? AppColors.darkSurface : AppColors.lightSurface;
          }),
        ),
      ),
    );
  }
}
