import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'buttons/pressable_scale.dart';

/// Shared press feedback for tappable rows and cards. Matches [AppButton]: scale
/// via [PressableScale] and a selection haptic on activate.
class AppPressable extends StatelessWidget {
  const AppPressable({
    super.key,
    required this.child,
    this.onPressed,
    this.enabled = true,
    this.enableHaptics = true,
    this.onHighlight,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool enableHaptics;
  final ValueChanged<bool>? onHighlight;

  bool get _interactive => enabled && onPressed != null;

  void _activate() {
    if (!_interactive) {
      return;
    }
    if (enableHaptics) {
      HapticFeedback.selectionClick();
    }
    onPressed!.call();
  }

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      enabled: _interactive,
      onPressed: _interactive ? _activate : null,
      onHighlight: onHighlight,
      child: child,
    );
  }
}
