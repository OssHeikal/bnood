import 'package:flutter/material.dart';

/// Shell tab chrome state propagated after [ShellScaffold] consumes keyboard insets.
class ShellChromeScope extends InheritedWidget {
  const ShellChromeScope({
    super.key,
    required this.keyboardOpen,
    required super.child,
  });

  final bool keyboardOpen;

  static bool keyboardOpenOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShellChromeScope>()?.keyboardOpen ?? false;
  }

  @override
  bool updateShouldNotify(ShellChromeScope oldWidget) => keyboardOpen != oldWidget.keyboardOpen;
}