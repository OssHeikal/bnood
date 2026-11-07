import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/money/ledger_math.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/statements/pdf_statement_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('client pdf generates non-empty bytes', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'PDF Client');
    final project = (await repo.primaryActiveProject(client.id))!;
    final item = (await repo.watchActiveItems().first).first;
    await repo.insertTransaction(
      projectId: project.id,
      kind: 'receive',
      amountPiastres: 500000,
      date: DateTime(2025, 3, 1),
      method: 'cash',
    );
    await repo.insertTransaction(
      projectId: project.id,
      kind: 'spend',
      amountPiastres: 100000,
      date: DateTime(2025, 3, 5),
      method: 'cash',
      itemId: item.id,
      expenseType: 'materials',
    );
    final rows = await repo.transactionsForProject(project.id);
    final totals = LedgerMath.periodTotals(
      projectRows: rows,
      periodStart: DateTime(2025, 3, 1),
      periodEnd: DateTime(2025, 3, 31),
    );
    final spend = rows.where((t) => t.kind == 'spend').toList();
    final recv = rows.where((t) => t.kind == 'receive').toList();
    final bytes = await PdfStatementService().buildClientStatement(
      client: client,
      totals: totals,
      periodSpend: spend,
      periodReceive: recv,
      itemNames: {item.id: item.name},
      periodStart: DateTime(2025, 3, 1),
      periodEnd: DateTime(2025, 3, 31),
    );
    expect(bytes.isNotEmpty, isTrue);
    expect(bytes.length, greaterThan(500));
  });
}
