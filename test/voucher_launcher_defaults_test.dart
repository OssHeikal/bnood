import 'package:bnood/features/vouchers/voucher_draft.dart';
import 'package:bnood/features/vouchers/voucher_launcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home generic add defaults draft to spend', () {
    final draft = VoucherLauncher.draftForFreshEntry(date: DateTime(2026, 11, 7));
    expect(draft.kind, 'spend');
    expect(draft.clientId, isNull);
    expect(draft.editingTransactionId, isNull);
  });

  test('VoucherDraft.fresh provider seed stays receive until launcher sets home draft', () {
    expect(VoucherDraft.fresh.kind, 'receive');
  });

  test('contextual client receive keeps receive', () {
    const draft = VoucherDraft(
      clientId: 'c1',
      projectId: 'p1',
      kind: 'receive',
      date: null,
    );
    expect(draft.kind, 'receive');
  });

  test('contextual client spend keeps spend', () {
    const draft = VoucherDraft(
      clientId: 'c1',
      projectId: 'p1',
      kind: 'spend',
    );
    expect(draft.kind, 'spend');
  });

  test('edit draft preserves stored transaction kind', () {
    const receiveEdit = VoucherDraft(
      clientId: 'c1',
      projectId: 'p1',
      kind: 'receive',
      editingTransactionId: 't1',
      amountPiastres: 5000,
    );
    const spendEdit = VoucherDraft(
      clientId: 'c1',
      projectId: 'p1',
      kind: 'spend',
      expenseType: 'labor',
      editingTransactionId: 't2',
      amountPiastres: 8000,
    );
    expect(receiveEdit.kind, 'receive');
    expect(spendEdit.kind, 'spend');
    expect(receiveEdit.editingTransactionId, 't1');
  });
}
