import 'package:bnood/features/vouchers/voucher_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('client change clears craftsman payee', () {
    const d = VoucherDraft(
      clientId: 'c1',
      craftsmanId: 'x',
      expenseType: 'labor',
    );
    final next = d.copyWith(clientId: 'c2', clearCraftsman: true);
    expect(next.craftsmanId, isNull);
  });

  test('materials labor toggle clears payees', () {
    const d = VoucherDraft(
        supplierId: 's', craftsmanId: 'c', expenseType: 'materials');
    final next = d.copyWith(
        expenseType: 'labor', clearSupplier: true, clearCraftsman: true);
    expect(next.supplierId, isNull);
    expect(next.craftsmanId, isNull);
  });
}
