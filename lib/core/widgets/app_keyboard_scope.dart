import 'package:flutter/material.dart';

/// Dismisses the primary focus when the user taps outside editable fields,
/// without blocking buttons, modal barriers, or other tappable widgets.
class AppKeyboardScope extends StatelessWidget {
  const AppKeyboardScope({super.key, required this.child});

  final Widget child;

  static bool _shouldDismissFocus(FocusNode? focus) {
    if (focus == null || !focus.hasPrimaryFocus) return false;
    final ctx = focus.context;
    if (ctx == null) return false;
    return ctx.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  static void _onTap() {
    final focus = FocusManager.instance.primaryFocus;
    if (!_shouldDismissFocus(focus)) return;
    focus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // [onTap] + deferToChild: taps on text fields and buttons stay with the child;
    // pointer-down on sheet drag does not unfocus; barrier taps stay on the barrier.
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: _onTap,
      child: child,
    );
  }
}