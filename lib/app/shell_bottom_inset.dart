import 'package:flutter/material.dart';

import '../core/config/theme/app_size.dart';
import 'shell_chrome_scope.dart';
import 'widgets/floating_shell_dock.dart';

/// Bottom chrome clearance for tab screens inside [ShellScaffold].
abstract final class ShellBottomInset {
  static bool keyboardObscuresDock(BuildContext context) {
    if (ShellChromeScope.keyboardOpenOf(context)) return true;
    return MediaQuery.viewInsetsOf(context).bottom > 0;
  }

  /// Extra [MediaQuery.padding] bottom for shell dock clearance (0 when keyboard is open).
  static double mediaQueryDockClearance(BuildContext context) {
    if (keyboardObscuresDock(context)) return 0;
    return FloatingShellDock.clearanceHeight;
  }

  /// List / scroll footer padding above home indicator and dock.
  static double listScrollBottomPadding(BuildContext context) {
    if (keyboardObscuresDock(context)) {
      return AppSize.spaceMD;
    }
    return FloatingShellDock.clearanceHeight +
        MediaQuery.viewPaddingOf(context).bottom +
        AppSize.spaceLG;
  }
}