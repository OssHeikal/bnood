import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api/auth_api_exception.dart';
import '../../core/vouchers/app_voucher_record.dart';
import '../../core/vouchers/vouchers_error_handler.dart';
import '../../core/vouchers/vouchers_riverpod.dart';
import '../../core/money/remote_money_format.dart';
import '../../core/providers/dashboard_providers.dart';
import '../../core/shared/pagination/paging_refresh.dart';
import '../../core/widgets/app_toaster.dart';
import '../providers/provider_detail_provider.dart';
import 'voucher_draft.dart';
import 'voucher_remote_receipts.dart';
import 'voucher_remote_save_result.dart';
import 'voucher_sheet_receipt.dart';

String voucherDatePayload(DateTime date) => DateFormat('y-MM-dd').format(date.toLocal());

Future<RemoteVoucherSaveResult> saveRemoteVoucher({
  required BuildContext context,
  required WidgetRef ref,
  required VoucherDraft draft,
  required int amountMinor,
  required String description,
  required List<VoucherSheetReceipt> receipts,
  List<String> pendingReceiptDeletes = const [],
}) async {
  final repo = ref.read(vouchersRepositoryProvider);
  final voucherDate = voucherDatePayload(draft.date ?? DateTime.now());
  final clientId = draft.clientId!;
  try {
    final AppVoucher voucher;
    if (draft.editingTransactionId != null) {
      voucher = await repo.patchVoucher(
        id: draft.editingTransactionId!,
        amountMinor: amountMinor,
        voucherDate: voucherDate,
        method: draft.method,
        description: description.isEmpty ? null : description,
        clearDescription: description.isEmpty,
        itemId: draft.kind == 'spend' ? draft.itemId : null,
        providerId: draft.kind == 'spend'
            ? (draft.expenseType == 'labor' ? draft.craftsmanId : draft.supplierId)
            : null,
        expenseClassification: draft.kind == 'spend' ? draft.expenseType : null,
        clearProvider: draft.kind == 'spend' &&
            draft.expenseType == 'materials' &&
            draft.supplierId == null,
      );
    } else {
      voucher = await repo.createVoucher(
        clientId: clientId,
        type: draft.kind,
        amountMinor: amountMinor,
        voucherDate: voucherDate,
        method: draft.method,
        description: description.isEmpty ? null : description,
        itemId: draft.kind == 'spend' ? draft.itemId : null,
        providerId: draft.kind == 'spend'
            ? (draft.expenseType == 'labor' ? draft.craftsmanId : draft.supplierId)
            : null,
        expenseClassification: draft.kind == 'spend' ? draft.expenseType : null,
      );
    }

    refreshAfterRemoteVoucherMutation(
      ref,
      clientId: clientId,
      providerId: draft.expenseType == 'labor'
          ? draft.craftsmanId
          : draft.expenseType == 'materials'
              ? draft.supplierId
              : null,
    );

    final sync = await syncVoucherReceiptsOnSave(
      repo: repo,
      voucherId: voucher.id,
      receiptIdsToDelete: pendingReceiptDeletes,
      receipts: receipts,
    );

    return RemoteVoucherSaveResult(
      voucherSaved: true,
      voucher: voucher,
      receipts: sync.receipts,
      failedReceiptUploads: sync.failedUploadCount,
      failedReceiptDeletes: sync.failedDeleteCount,
      failedDeleteReceiptIds: sync.failedDeleteIds,
      deletedReceiptIds: sync.deletedReceiptIds,
      lastReceiptError: sync.lastReceiptError,
    );
  } on AuthApiException catch (e) {
    if (!context.mounted) {
      return const RemoteVoucherSaveResult(voucherSaved: false);
    }
    if (await handleVouchersApiAuthError(context: context, ref: ref, error: e)) {
      return const RemoteVoucherSaveResult(voucherSaved: false);
    }
    AppToaster.show(e.message, kind: ToastKind.failure);
    return const RemoteVoucherSaveResult(voucherSaved: false);
  }
}

Future<bool> deleteRemoteVoucher({
  required BuildContext context,
  required WidgetRef ref,
  required VoucherDraft draft,
}) async {
  final id = draft.editingTransactionId;
  if (id == null) return false;
  try {
    await ref.read(vouchersRepositoryProvider).deleteVoucher(id);
    refreshAfterRemoteVoucherMutation(
      ref,
      clientId: draft.clientId,
      providerId: draft.expenseType == 'labor'
          ? draft.craftsmanId
          : draft.expenseType == 'materials'
              ? draft.supplierId
              : null,
    );
    return true;
  } on AuthApiException catch (e) {
    if (!context.mounted) return false;
    if (await handleVouchersApiAuthError(context: context, ref: ref, error: e)) {
      return false;
    }
    if (context.mounted) {
      AppToaster.show(e.message, kind: ToastKind.failure);
    }
    return false;
  }
}

void refreshAfterRemoteVoucherMutation(
  WidgetRef ref, {
  String? clientId,
  String? providerId,
}) {
  refreshAfterClientMutation(ref, clientId: clientId);
  if (clientId != null) {
    bumpPagingListRefresh(ref, PagingListIds.clientMovements(clientId));
  }
  if (providerId != null) {
    ref.read(providerDetailProvider(providerId).notifier).refreshSilently();
  }
}

int? parseVoucherAmountInput(String text, {required bool remote}) {
  return remote ? RemoteMoneyFormat.parseMajorInput(text) : null;
}
