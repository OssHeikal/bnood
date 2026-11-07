import 'package:flutter/material.dart';

import '../../core/config/theme/app_size.dart';
import '../../core/widgets/app_toaster.dart' show rootScaffoldMessengerKey;
import '../../core/widgets/toast/app_toast.dart';
import '../../core/widgets/toast/app_tone.dart';
import '../home/home_foundation_scope.dart';

/// Theme-aware toasts on statement routes; uses app-root messenger + foundation theme.
abstract final class StatementScreenToast {
  static void failure(
    BuildContext context,
    String message, {
    ToastAction? action,
  }) {
    if (!context.mounted) return;
    final messenger = rootScaffoldMessengerKey.currentState ?? ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final footerClearance = AppSize.buttonHeight + AppSize.spaceMD + AppSize.spaceSM;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: HomeFoundationScope(
            child: Builder(
              builder: (ctx) => AppToast(
                tone: AppTone.danger,
                message: message,
                action: action,
              ),
            ),
          ),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          margin: EdgeInsetsDirectional.only(
            start: AppSize.spaceMD,
            end: AppSize.spaceMD,
            bottom: footerClearance + bottomInset + AppSize.spaceMD,
          ),
        ),
      );
  }
}
