import 'package:flutter/material.dart';

/// Dismisses the primary focus when the user taps outside editable fields,
/// without blocking buttons and other tappable widgets.
class AppKeyboardScope extends StatelessWidget {
  const AppKeyboardScope({super.key, required this.child});

  final Widget child;

  static bool _shouldDismissFocus(FocusNode? focus) {
    if (focus == null || !focus.hasPrimaryFocus) return false;
    final ctx = focus.context;
    if (ctx == null) return false;
    return ctx.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: () {
        final focus = FocusManager.instance.primaryFocus;
        if (_shouldDismissFocus(focus)) {
          focus?.unfocus();
        }
      },
      child: child,
    );
  }
}