import 'package:bnood/core/money/ledger_math.dart';
import 'package:bnood/core/money/period_bounds.dart';
import 'package:bnood/core/money/supplier_period_math.dart';
import 'package:bnood/core/database/database.dart';
import 'package:flutter_test/flutter_test.dart';

Transaction _spend(int amount, DateTime d) => Transaction(
      id: 'x',
      workspaceId: 'w',
      projectId: 'p',
      kind: 'spend',
      amountPiastres: amount,
      date: d,
      method: 'cash',
      description: null,
      receiptImagePath: null,
      itemId: 'i',
      expenseType: 'materials',
      supplierId: 's',
      craftsmanId: null,
      createdAt: d,
      updatedAt: d,
    );

void main() {
  test('client closing = opening + receive - spend', () {
    final bounds = PeriodBounds.normalize(
      start: DateTime(2025, 3, 1),
      end: DateTime(2025, 3, 31),
    );
    final rows = [
      Transaction(
        id: '1',
        workspaceId: 'w',
        projectId: 'p',
        kind: 'receive',
        amountPiastres: 100000,
        date: DateTime(2025, 2, 20),
        method: 'cash',
        description: null,
        receiptImagePath: null,
        itemId: null,
        expenseType: null,
        supplierId: null,
        craftsmanId: null,
        createdAt: DateTime(2025, 2, 20),
        updatedAt: DateTime(2025, 2, 20),
      ),
      Transaction(
        id: '2',
        workspaceId: 'w',
        projectId: 'p',
        kind: 'receive',
        amountPiastres: 50000,
        date: DateTime(2025, 3, 10),
        method: 'cash',
        description: null,
        receiptImagePath: null,
        itemId: null,
        expenseType: null,
        supplierId: null,
        craftsmanId: null,
        createdAt: DateTime(2025, 3, 10),
        updatedAt: DateTime(2025, 3, 10),
      ),
      _spend(20000, DateTime(2025, 3, 15)),
    ];
    final t = LedgerMath.periodTotals(
      projectRows: rows,
      periodStart: bounds.start,
      periodEnd: bounds.end,
    );
    expect(t.openingBalancePiastres, 100000);
    expect(t.periodReceivedPiastres, 50000);
    expect(t.periodSpentPiastres, 20000);
    expect(
        t.closingBalancePiastres,
        t.openingBalancePiastres +
            t.periodReceivedPiastres -
            t.periodSpentPiastres);
  });

  test('empty period keeps opening from prior activity', () {
    final bounds = PeriodBounds.normalize(
      start: DateTime(2025, 5, 1),
      end: DateTime(2025, 5, 31),
    );
    final rows = [
      Transaction(
        id: '1',
        workspaceId: 'w',
        projectId: 'p',
        kind: 'receive',
        amountPiastres: 30000,
        date: DateTime(2025, 4, 1),
        method: 'cash',
        description: null,
        receiptImagePath: null,
        itemId: null,
        expenseType: null,
        supplierId: null,
        craftsmanId: null,
        createdAt: DateTime(2025, 4, 1),
        updatedAt: DateTime(2025, 4, 1),
      ),
    ];
    final t = LedgerMath.periodTotals(
      projectRows: rows,
      periodStart: bounds.start,
      periodEnd: bounds.end,
    );
    expect(t.periodReceivedPiastres, 0);
    expect(t.closingBalancePiastres, t.openingBalancePiastres);
  });

  test('supplier closing = opening + period', () {
    final bounds = PeriodBounds.normalize(
      start: DateTime(2025, 3, 1),
      end: DateTime(2025, 3, 31),
    );
    final rows = [
      _spend(10000, DateTime(2025, 2, 1)),
      _spend(5000, DateTime(2025, 3, 5)),
    ];
    final t = SupplierPeriodMath.totals(supplierSpends: rows, bounds: bounds);
    expect(t.closingPaidPiastres, t.openingPaidPiastres + t.periodPaidPiastres);
  });
}
