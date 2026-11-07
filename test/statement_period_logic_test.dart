import 'package:bnood/core/database/database.dart';
import 'package:bnood/features/statements/statement_export_store.dart';
import 'package:bnood/features/statements/statement_period_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('since last export returns null with no prior export', () {
    expect(StatementPeriodLogic.sinceLastExportBounds(null), isNull);
  });

  test('since last export starts day after stored period end', () {
    final record = StatementExportRecord(
      exportedAt: DateTime(2025, 6, 15, 18, 0),
      periodEndInclusive: DateTime(2025, 6, 10),
    );
    final bounds = StatementPeriodLogic.sinceLastExportBounds(record);
    expect(bounds, isNotNull);
    expect(bounds!.start.year, 2025);
    expect(bounds.start.month, 6);
    expect(bounds.start.day, 11);
  });

  test('all time bounds include earliest and latest transaction dates', () {
    final rows = [
      Transaction(
        id: '1',
        workspaceId: 'w',
        projectId: 'p',
        kind: 'receive',
        amountPiastres: 100,
        date: DateTime(2025, 1, 5),
        method: 'cash',
        description: null,
        receiptImagePath: null,
        itemId: null,
        expenseType: null,
        supplierId: null,
        craftsmanId: null,
        createdAt: DateTime(2025, 1, 5),
        updatedAt: DateTime(2025, 1, 5),
      ),
      Transaction(
        id: '2',
        workspaceId: 'w',
        projectId: 'p',
        kind: 'spend',
        amountPiastres: 50,
        date: DateTime(2025, 4, 20),
        method: 'cash',
        description: null,
        receiptImagePath: null,
        itemId: null,
        expenseType: 'materials',
        supplierId: null,
        craftsmanId: null,
        createdAt: DateTime(2025, 4, 20),
        updatedAt: DateTime(2025, 4, 20),
      ),
    ];
    final b = StatementPeriodLogic.allTimeBounds(rows);
    expect(b.start.day, 5);
    expect(b.start.month, 1);
    expect(b.end.isBefore(DateTime.now().add(const Duration(days: 1))), isTrue);
    expect(b.start.month, 1);
  });
}
