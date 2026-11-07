import 'package:flutter/material.dart';

import '../../config/extensions/text_style_extensions.dart';
import '../../config/theme/app_size.dart';
import '../../config/theme/app_text.dart';

enum AppButtonStyle {
  primary,
  secondary,
  destructive,
  success,
  warning,
  outlined,
  text,
  icon,
}

enum AppButtonSize { small, medium, large }

/// Where a label and its icon sit in a wide button.
enum AppButtonContentAlign { spaceBetween, center }

/// Idle, pressed, disabled, and loading. Disabled wins, then loading.
enum AppButtonPhase { idle, pressed, disabled, loading }

AppButtonPhase buttonPhase({
  required bool enabled,
  required bool loading,
  required bool pressed,
}) {
  if (!enabled) {
    return AppButtonPhase.disabled;
  }
  if (loading) {
    return AppButtonPhase.loading;
  }
  if (pressed) {
    return AppButtonPhase.pressed;
  }
  return AppButtonPhase.idle;
}

/// iOS keeps 44pt. Android and the other platforms use 48dp.
double buttonHitTarget(TargetPlatform platform) {
  return switch (platform) {
    TargetPlatform.iOS => AppSize.hitMin,
    _ => AppSize.hitMinAndroid,
  };
}

/// Rejects labels that name the control instead of the action.
bool isActionLabel(String text) {
  final normalized = text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  const blocked = {
    'ok',
    'okay',
    'click',
    'click here',
    'button',
    'tap here',
    'press here',
  };
  return !blocked.contains(normalized);
}

extension AppButtonSizeMetrics on AppButtonSize {
  double get minHeight => switch (this) {
    AppButtonSize.small => AppSize.buttonHeightSmall,
    AppButtonSize.medium => AppSize.buttonHeight,
    AppButtonSize.large => AppSize.buttonHeightLarge,
  };

  double get horizontalPadding => switch (this) {
    AppButtonSize.small => AppSize.spaceMD,
    AppButtonSize.medium => AppSize.spaceLG,
    AppButtonSize.large => AppSize.spaceXL,
  };

  double get iconSize => switch (this) {
    AppButtonSize.small || AppButtonSize.medium => AppSize.iconCompact,
    AppButtonSize.large => AppSize.icon,
  };

  double get gap => switch (this) {
    AppButtonSize.small => AppSize.spaceXS,
    AppButtonSize.medium => AppSize.spaceSM,
    AppButtonSize.large => AppSize.spaceMD,
  };

  TextStyle textStyle(AppText text) => switch (this) {
    AppButtonSize.small => text.label,
    AppButtonSize.medium => text.button,
    AppButtonSize.large => text.bodyLarge.semiBold,
  };
}
