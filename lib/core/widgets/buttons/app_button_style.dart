import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import 'app_button_type.dart';

/// Surface, ink, and the optional border and shadow for one button.
class AppButtonColors {
  const AppButtonColors({
    required this.surface,
    required this.foreground,
    this.border,
    this.shadow,
  });

  final Color surface;
  final Color foreground;
  final Color? border;
  final BoxShadow? shadow;

  AppButtonColors copyWith({Color? surface, Color? foreground, Color? border, BoxShadow? shadow}) {
    return AppButtonColors(
      surface: surface ?? this.surface,
      foreground: foreground ?? this.foreground,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
    );
  }

  /// WCAG AA contrast for normal text.
  static const minContrast = 4.5;

  static const _wcagLift = 0.05;

  /// Picks the enabled or disabled colors for [style]. Primary keeps
  /// [AppColors.onPrimary] on the brand fill; every other enabled style
  /// runs [readableInk].
  static AppButtonColors resolve(
    AppColors colors,
    AppButtonStyle style, {
    required bool disabled,
  }) {
    if (disabled) {
      return _disabled(colors, style);
    }
    final raw = _enabled(colors, style);
    if (style == AppButtonStyle.primary) {
      return raw;
    }
    return AppButtonColors(
      surface: raw.surface,
      foreground: readableInk(colors, raw.surface, raw.foreground),
      border: raw.border,
      shadow: raw.shadow,
    );
  }

  /// Applies caller overrides. A background without an ink re-picks the ink.
  /// Disabled buttons do not call this.
  AppButtonColors overriding({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    BoxShadow? boxShadow,
    required AppColors colors,
  }) {
    final nextSurface = backgroundColor ?? surface;
    final Color nextForeground;
    if (foregroundColor != null) {
      nextForeground = foregroundColor;
    } else if (backgroundColor != null) {
      nextForeground = readableInk(colors, nextSurface, foreground);
    } else {
      nextForeground = foreground;
    }
    return AppButtonColors(
      surface: nextSurface,
      foreground: nextForeground,
      border: borderColor ?? border,
      shadow: boxShadow ?? shadow,
    );
  }

  /// Keeps [preferred] when it clears [minContrast] on [surface] composited
  /// over the page. Otherwise picks the stronger of that ink, light-theme
  /// text, and dark-theme text.
  static Color readableInk(AppColors colors, Color surface, Color preferred) {
    final backdrop = composite(surface, colors.canvas);
    if (contrast(preferred, backdrop) >= minContrast) {
      return preferred;
    }
    final candidates = [
      preferred,
      AppColors.light.onSurface,
      AppColors.dark.onSurface,
    ];
    var best = preferred;
    var bestScore = contrast(preferred, backdrop);
    for (final candidate in candidates) {
      final score = contrast(candidate, backdrop);
      if (score > bestScore) {
        best = candidate;
        bestScore = score;
      }
    }
    return best;
  }

  static double contrast(Color a, Color b) {
    final left = a.computeLuminance();
    final right = b.computeLuminance();
    final lighter = math.max(left, right);
    final darker = math.min(left, right);
    return (lighter + _wcagLift) / (darker + _wcagLift);
  }

  /// Paints [surface] over [backdrop] so a transparent fill is scored
  /// against the page.
  static Color composite(Color surface, Color backdrop) {
    final alpha = surface.a;
    if (alpha >= 1) {
      return surface;
    }
    final rest = 1 - alpha;
    return Color.from(
      alpha: 1,
      red: surface.r * alpha + backdrop.r * rest,
      green: surface.g * alpha + backdrop.g * rest,
      blue: surface.b * alpha + backdrop.b * rest,
    );
  }

  static AppButtonColors _enabled(AppColors colors, AppButtonStyle style) {
    return switch (style) {
      AppButtonStyle.primary => AppButtonColors(
        surface: colors.primary,
        foreground: colors.onPrimary,
        shadow: colors.buttonShadow,
      ),
      AppButtonStyle.secondary || AppButtonStyle.outlined => AppButtonColors(
        surface: Colors.transparent,
        foreground: colors.primaryOnTint,
        border: colors.outline,
      ),
      AppButtonStyle.destructive => AppButtonColors(
        surface: colors.error,
        foreground: colors.onError,
        shadow: colors.buttonShadow,
      ),
      AppButtonStyle.success => AppButtonColors(
        surface: colors.success,
        foreground: colors.onSolid,
        shadow: colors.buttonShadow,
      ),
      AppButtonStyle.warning => _warning(colors),
      AppButtonStyle.text => AppButtonColors(
        surface: Colors.transparent,
        foreground: colors.primary,
      ),
      AppButtonStyle.icon => AppButtonColors(
        surface: Colors.transparent,
        foreground: colors.onSurface,
      ),
    };
  }

  static AppButtonColors _warning(AppColors colors) {
    final surface = contrast(colors.onSolid, colors.warning) >= minContrast
        ? colors.warning
        : colors.warningStrong;
    return AppButtonColors(
      surface: surface,
      foreground: colors.onSolid,
      shadow: colors.buttonShadow,
    );
  }

  static AppButtonColors _disabled(AppColors colors, AppButtonStyle style) {
    return switch (style) {
      AppButtonStyle.secondary || AppButtonStyle.outlined => AppButtonColors(
        surface: Colors.transparent,
        foreground: colors.textDisabled,
        border: colors.outlineSubtle,
      ),
      AppButtonStyle.text || AppButtonStyle.icon => AppButtonColors(
        surface: Colors.transparent,
        foreground: colors.textDisabled,
      ),
      _ => AppButtonColors(
        surface: colors.surfaceSunken,
        foreground: colors.textDisabled,
      ),
    };
  }
}
