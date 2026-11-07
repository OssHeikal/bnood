import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/theme/app_motion.dart';

/// Scales [child] while pressed. The detector sits outside the scale so the
/// hit target does not shrink under the finger.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    required this.onPressed,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
    this.onHighlight,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final ValueChanged<bool>? onHighlight;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  var _pressed = false;

  @override
  void didUpdateWidget(PressableScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _pressed) {
      _pressed = false;
    }
  }

  void _setPressed(bool pressed) {
    if (_pressed == pressed) {
      return;
    }
    setState(() => _pressed = pressed);
    widget.onHighlight?.call(pressed);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!widget.enabled) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final activate =
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.numpadEnter;
    if (!activate) {
      return KeyEventResult.ignored;
    }
    if (event is KeyDownEvent) {
      _setPressed(true);
      return KeyEventResult.handled;
    }
    if (event is KeyUpEvent) {
      _setPressed(false);
      widget.onPressed?.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      canRequestFocus: widget.enabled,
      onFocusChange: widget.onFocusChange,
      onKeyEvent: _onKey,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
        onTapUp: widget.enabled ? (_) => _setPressed(false) : null,
        onTapCancel: widget.enabled ? () => _setPressed(false) : null,
        onTap: widget.enabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _pressed ? AppMotion.pressScale : 1,
          duration: AppMotion.durationOf(context, AppMotion.pressDuration),
          curve: AppMotion.standard,
          child: widget.child,
        ),
      ),
    );
  }
}
