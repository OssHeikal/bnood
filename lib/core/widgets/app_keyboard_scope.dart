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

  static void _unfocusEditableIfNeeded() {
    final focus = FocusManager.instance.primaryFocus;
    if (_shouldDismissFocus(focus)) {
      focus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // [Listener] + deferToChild avoids competing with [ModalBarrier] tap-to-dismiss
    // in the gesture arena (unlike a wrapping [GestureDetector.onTap]).
    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: (_) => _unfocusEditableIfNeeded(),
      child: child,
    );
  }
}