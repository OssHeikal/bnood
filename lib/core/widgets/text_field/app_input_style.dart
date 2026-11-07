import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_size.dart';

class AppInputState {
  const AppInputState({
    this.disabled = false,
    this.invalid = false,
    this.focused = false,
  });

  final bool disabled;
  final bool invalid;
  final bool focused;
}

class AppInputStyle {
  const AppInputStyle({
    required this.surface,
    required this.border,
    required this.borderWidth,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.prefix,
    required this.suffix,
    required this.trailing,
    required this.helper,
    required this.counter,
    required this.error,
    required this.cursor,
  });

  final Color surface;
  final Color border;
  final double borderWidth;
  final Color label;
  final Color value;
  final Color placeholder;
  final Color prefix;
  final Color suffix;
  final Color trailing;
  final Color helper;
  final Color counter;
  final Color error;
  final Color cursor;

  static AppInputStyle resolve(AppColors colors, AppInputState state) {
    if (state.disabled) {
      return AppInputStyle(
        surface: colors.surfaceSunken,
        border: colors.surfaceSunken,
        borderWidth: AppSize.borderWidthHairline,
        label: colors.textDisabled,
        value: colors.textDisabled,
        placeholder: colors.textDisabled,
        prefix: colors.textDisabled,
        suffix: colors.textDisabled,
        trailing: colors.textDisabled,
        helper: colors.textDisabled,
        counter: colors.textDisabled,
        error: colors.textDisabled,
        cursor: colors.primary,
      );
    }

    final focused = state.focused && !state.invalid;
    return AppInputStyle(
      surface: colors.surface,
      border: state.invalid
          ? colors.error
          : focused
          ? colors.primary
          : colors.outline,
      borderWidth: state.invalid || state.focused
          ? AppSize.borderWidth
          : AppSize.borderWidthHairline,
      label: focused ? colors.primary : colors.muted,
      value: colors.onSurface,
      placeholder: colors.textTertiary,
      prefix: colors.onSurface,
      suffix: colors.muted,
      trailing: colors.muted,
      helper: colors.muted,
      counter: state.invalid ? colors.error : colors.textTertiary,
      error: colors.error,
      cursor: colors.primary,
    );
  }
}
