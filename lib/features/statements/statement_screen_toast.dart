import 'package:flutter/material.dart';

import '../../core/widgets/app_toaster.dart';

/// Statement export failures — same [AppToaster] with export-footer clearance.
abstract final class StatementScreenToast {
  static void failure(
    BuildContext context,
    String message, {
    ToastAction? action,
  }) {
    if (!context.mounted) return;
    AppToaster.failure(
      message,
      layoutContext: context,
      layout: AppToastLayoutHint.statementExportFooter,
      action: action,
    );
  }
}
