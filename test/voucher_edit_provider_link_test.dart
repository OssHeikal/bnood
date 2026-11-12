import 'package:bnood/core/vouchers/app_voucher_record.dart';
import 'package:bnood/features/vouchers/voucher_draft_from_app_voucher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('editing spend voucher from remote record marks provider as already linked', () {
    final voucher = AppVoucher(
      id: 'voucher-1',
      clientId: 'client-1',
      type: 'spend',
      amountMinor: 50_000,
      voucherDate: DateTime.utc(2026, 3, 1),
      method: 'cash',
      itemId: 'item-1',
      providerId: 'supplier-1',
      expenseClassification: 'materials',
      providerName: 'Supplier',
    );

    final draft = voucherDraftFromAppVoucher(voucher, projectId: 'project-1', clientId: 'client-1');

    expect(draft.editingTransactionId, 'voucher-1');
    expect(draft.supplierId, 'supplier-1');
    expect(draft.providerLinkedToClient, isTrue);
  });
}
