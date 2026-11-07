import 'package:bnood/core/database/database.dart';
import 'package:bnood/core/money/ledger_math.dart';
import 'package:flutter_test/flutter_test.dart';

Transaction _tx({
  required String kind,
  required int amount,
  required DateTime date,
  String? expenseType,
  String? craftsmanId,
  String? itemId,
}) {
  return Transaction(
    id: 't',
    workspaceId: 'w',
    projectId: 'p',
    kind: kind,
    amountPiastres: amount,
    date: date,
    method: 'cash',
    description: null,
    receiptImagePath: null,
    itemId: itemId,
    expenseType: expenseType,
    supplierId: null,
    craftsmanId: craftsmanId,
    createdAt: date,
    updatedAt: date,
  );
}

void main() {
  test('project balance receive minus spend', () {
    final rows = [
      _tx(kind: 'receive', amount: 2000000, date: DateTime(2025, 1, 1)),
      _tx(
          kind: 'spend',
          amount: 500000,
          date: DateTime(2025, 1, 2),
          expenseType: 'materials',
          itemId: 'i'),
      _tx(
          kind: 'spend',
          amount: 300000,
          date: DateTime(2025, 1, 3),
          expenseType: 'labor',
          itemId: 'i',
          craftsmanId: 'c'),
    ];
    final b = LedgerMath.projectBalance(rows);
    expect(b.balancePiastres, 1200000);
  });

  test('craftsman remaining only when agreement set', () {
    expect(
        LedgerMath.craftsmanRemainingPiastres(
            initialAmountPiastres: null, paidPiastres: 300000),
        isNull);
    expect(
        LedgerMath.craftsmanRemainingPiastres(
            initialAmountPiastres: 800000, paidPiastres: 300000),
        500000);
  });

  test('statement period opening and closing', () {
    final rows = [
      _tx(kind: 'receive', amount: 1000000, date: DateTime(2025, 1, 5)),
      _tx(kind: 'receive', amount: 500000, date: DateTime(2025, 2, 1)),
      _tx(
          kind: 'spend',
          amount: 200000,
          date: DateTime(2025, 2, 10),
          expenseType: 'materials',
          itemId: 'i'),
    ];
    final totals = LedgerMath.periodTotals(
      projectRows: rows,
      periodStart: DateTime(2025, 2, 1),
      periodEnd: DateTime(2025, 2, 28),
    );
    expect(totals.openingBalancePiastres, 1000000);
    expect(totals.periodReceivedPiastres, 500000);
    expect(totals.periodSpentPiastres, 200000);
    expect(totals.closingBalancePiastres, 1300000);
  });
}
