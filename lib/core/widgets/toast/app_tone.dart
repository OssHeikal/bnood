import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../foundation_icon.dart';

enum AppTone { neutral, brand, warning, danger, success, info }

extension AppToneColors on AppTone {
  Color tint(AppColors colors) => switch (this) {
        AppTone.neutral => colors.surfaceSunken,
        AppTone.brand => colors.primaryTint,
        AppTone.warning => colors.warningBg,
        AppTone.danger => colors.errorBg,
        AppTone.success => colors.successBg,
        AppTone.info => colors.infoBg,
      };

  Color glyph(AppColors colors) => switch (this) {
        AppTone.neutral => colors.muted,
        AppTone.brand => colors.primaryOnTint,
        AppTone.warning => colors.warning,
        AppTone.danger => colors.error,
        AppTone.success => colors.success,
        AppTone.info => colors.infoOnTint,
      };

  Color solid(AppColors colors) => switch (this) {
        AppTone.neutral => colors.outline,
        AppTone.brand => colors.primary,
        AppTone.warning => colors.warning,
        AppTone.danger => colors.error,
        AppTone.success => colors.success,
        AppTone.info => colors.info,
      };

  /// Toast / decision chip glyph. Warning stays Material (no DS asset).
  Widget glyphWidget({required double size, required Color color}) {
    switch (this) {
      case AppTone.success:
        return FoundationIcon(Icons.check_circle_outline, size: size, color: color);
      case AppTone.danger:
        return FoundationIcon(Icons.close, size: size, color: color);
      case AppTone.warning:
        return Icon(Icons.warning_amber_rounded, size: size, color: color);
      case AppTone.neutral:
      case AppTone.brand:
      case AppTone.info:
        return FoundationIcon(Icons.info_outline, size: size, color: color);
    }
  }

  /// Used by tests for the one tone that still uses Material.
  IconData? get materialTestIcon => switch (this) {
        AppTone.warning => Icons.warning_amber_rounded,
        _ => null,
      };
}
