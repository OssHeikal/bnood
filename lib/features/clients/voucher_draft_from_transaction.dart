import '../../core/database/database.dart';
import '../../core/repositories/bnood_repository.dart';
import '../vouchers/voucher_draft.dart';

Future<VoucherDraft?> voucherDraftFromTransaction(
  BnoodRepository repo,
  Transaction transaction, {
  String? clientLabel,
}) async {
  final project = await repo.projectById(transaction.projectId);
  if (project == null) return null;
  final client = await repo.getClient(project.clientId);
  final hasLinkedProvider = transaction.kind == 'spend' &&
      (transaction.supplierId != null || transaction.craftsmanId != null);
  return VoucherDraft(
    clientId: project.clientId,
    projectId: transaction.projectId,
    clientLabel: clientLabel ?? client.name,
    kind: transaction.kind,
    expenseType: transaction.expenseType ?? 'materials',
    method: transaction.method,
    amountPiastres: transaction.amountPiastres,
    itemId: transaction.itemId,
    supplierId: transaction.supplierId,
    craftsmanId: transaction.craftsmanId,
    description: transaction.description,
    date: transaction.date,
    editingTransactionId: transaction.id,
    receiptImagePath: transaction.receiptImagePath,
    providerLinkedToClient: hasLinkedProvider ? true : null,
  );
}
