import '../../core/repositories/bnood_repository.dart';
import 'voucher_draft.dart';

/// Resolves display labels for edit drafts that only carry entity ids.
Future<VoucherDraft> enrichVoucherDraft(BnoodRepository repo, VoucherDraft draft) async {
  var next = draft;

  if (next.clientLabel == null && next.clientId != null) {
    final client = await repo.getClient(next.clientId!);
    if (client != null) {
      next = next.copyWith(clientLabel: client.name);
    }
  }

  if (next.receiptImagePath == null && next.editingTransactionId != null) {
    final tx = await repo.getTransaction(next.editingTransactionId!);
    if (tx?.receiptImagePath != null) {
      next = next.copyWith(receiptImagePath: tx!.receiptImagePath);
    }
  }

  if (next.itemLabel == null && next.itemId != null) {
    final item = await repo.getItem(next.itemId!);
    if (item != null) {
      next = next.copyWith(itemLabel: item.name);
    }
  }

  if (next.supplierLabel == null && next.supplierId != null) {
    final supplier = await repo.getSupplier(next.supplierId!);
    if (supplier != null) {
      next = next.copyWith(supplierLabel: supplier.name);
    }
  }

  if (next.craftsmanLabel == null && next.craftsmanId != null) {
    final craftsman = await repo.getCraftsman(next.craftsmanId!);
    if (craftsman != null) {
      next = next.copyWith(craftsmanLabel: craftsman.name);
    }
  }

  return next;
}
