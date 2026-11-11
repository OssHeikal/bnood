import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/bnood_form_route_canvas.dart';
import '../../core/widgets/app_decision.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/toast/app_tone.dart';
import '../home/home_foundation_scope.dart';
import 'voucher_draft.dart';
import 'voucher_launcher.dart';
import 'voucher_sheet.dart';

class VoucherScreen extends ConsumerWidget {
  const VoucherScreen({super.key});

  static const path = '/voucher';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(voucherDraftProvider);
    final l10n = AppLocalizations.of(context);
    final isSpend = draft.kind == 'spend';
    final isEditing = draft.editingTransactionId != null;
    final title = isEditing ? l10n.edit : (isSpend ? l10n.voucherSpendTitle : l10n.voucherReceiveTitle);

    return BnoodFormRouteCanvas(
      child: HomeFoundationScope(
        child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          await _handleBack(context, ref);
        },
        child: Scaffold(
          appBar: CustomAppBar(
            title: title,
            leading: BackButton(onPressed: () => _handleBack(context, ref)),
          ),
          body: VoucherSheet(
            key: voucherSheetStateKey,
            presentation: VoucherSheetPresentation.fullScreen,
          ),
          ),
        ),
      ),
    );
  }

  static Future<void> _handleBack(BuildContext context, WidgetRef ref) async {
    final sheet = voucherSheetStateKey.currentState;
    if (sheet != null && sheet.hasNestedRouteToPop) {
      Navigator.of(context).pop();
      return;
    }
    final dirty = sheet?.hasUnsavedChanges() ?? false;
    if (dirty) {
      final l10n = AppLocalizations.of(context);
      final answer = await AppDecision.show(
        context,
        title: l10n.voucherDiscardTitle,
        description: l10n.voucherDiscardDescription,
        confirmLabel: l10n.discard,
        cancelLabel: l10n.cancel,
        tone: AppTone.danger,
      );
      if (answer != OverlayAnswer.confirmed || !context.mounted) return;
    }
    if (context.mounted) context.pop();
  }
}

bool voucherDraftsEqual(VoucherDraft a, VoucherDraft b) {
  return a.clientId == b.clientId &&
      a.projectId == b.projectId &&
      a.clientLabel == b.clientLabel &&
      a.kind == b.kind &&
      a.expenseType == b.expenseType &&
      a.method == b.method &&
      a.amountPiastres == b.amountPiastres &&
      a.itemId == b.itemId &&
      a.supplierId == b.supplierId &&
      a.craftsmanId == b.craftsmanId &&
      a.description == b.description &&
      a.editingTransactionId == b.editingTransactionId &&
      a.receiptImagePath == b.receiptImagePath &&
      a.providerLinkedToClient == b.providerLinkedToClient;
}
