import '../../core/vouchers/app_voucher_record.dart';
import 'voucher_draft.dart';

VoucherDraft voucherDraftFromAppVoucher(
  AppVoucher voucher, {
  required String projectId,
  String? clientId,
}) {
  final hasLinkedProvider = voucher.isSpend &&
      (voucher.supplierId != null || voucher.craftsmanId != null);
  return VoucherDraft(
    clientId: clientId ?? voucher.clientId,
    projectId: projectId,
    clientLabel: voucher.clientName,
    kind: voucher.type,
    expenseType: voucher.expenseClassification ?? 'materials',
    method: voucher.method,
    amountPiastres: voucher.amountMinor,
    itemId: voucher.itemId,
    itemLabel: voucher.itemName,
    supplierId: voucher.supplierId,
    supplierLabel: voucher.expenseClassification == 'materials' ? voucher.providerName : null,
    craftsmanId: voucher.craftsmanId,
    craftsmanLabel: voucher.expenseClassification == 'labor' ? voucher.providerName : null,
    description: voucher.description,
    date: voucher.voucherDate,
    editingTransactionId: voucher.id,
    providerLinkedToClient: hasLinkedProvider ? true : null,
  );
}
