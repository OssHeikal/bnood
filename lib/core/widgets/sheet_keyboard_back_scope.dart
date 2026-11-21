import 'package:flutter/material.dart';

/// On modal sheets: while the keyboard is open and a field has focus, back unfocuses only.
class SheetKeyboardBackScope extends StatelessWidget {
  const SheetKeyboardBackScope({super.key, required this.child});

  final Widget child;

  static bool _fieldHasPrimaryFocus() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus == null || !focus.hasFocus) return false;
    final ctx = focus.context;
    if (ctx == null) return false;
    return ctx.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  static bool _keyboardOpen(BuildContext context) {
    return MediaQuery.viewInsetsOf(context).bottom > 0;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = _keyboardOpen(context);
    return PopScope(
      canPop: !(keyboardOpen && _fieldHasPrimaryFocus()),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_keyboardOpen(context) && _fieldHasPrimaryFocus()) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: child,
    );
  }
}