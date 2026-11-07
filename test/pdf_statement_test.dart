import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/money/ledger_math.dart';
import 'package:bnood/core/money/period_bounds.dart';
import 'package:bnood/core/pdf/pdf_fonts.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/statements/pdf_statement_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => PdfFonts.clearCache());

  test('client pdf uses bundled fonts without network', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'عميل PDF');
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
    final bounds = PeriodBounds.normalize(
      start: DateTime(2025, 3, 1),
      end: DateTime(2025, 3, 31),
    );
    final totals = LedgerMath.periodTotals(
      projectRows: rows,
      periodStart: bounds.start,
      periodEnd: bounds.end,
    );
    final spend = rows.where((t) => t.kind == 'spend').toList();
    final recv = rows.where((t) => t.kind == 'receive').toList();
    final bytes = await PdfStatementService().buildClientStatement(
      client: client,
      totals: totals,
      periodSpend: spend,
      periodReceive: recv,
      itemNames: {item.id: item.name},
      bounds: bounds,
    );
    expect(bytes.isNotEmpty, isTrue);
    expect(bytes.length, greaterThan(1500));
  });
}
