import 'dart:io';

import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/core/money/ledger_math.dart';
import 'package:bnood/core/money/period_bounds.dart';
import 'package:bnood/core/money/supplier_period_math.dart';
import 'package:bnood/core/pdf/pdf_fonts.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/statements/pdf_statement_service.dart';
import 'package:bnood/features/statements/statement_pdf_copy.dart';
import 'package:bnood/l10n/app_localizations_ar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => PdfFonts.clearCache());

  test('synthetic client PDF layout fixtures and multipage body', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    const unitAddress = 'الشيخ زايد - فيلا 12';
    final client = await repo.createClient(
      name: 'عميل تنسيق طويل الاسم للوحدات السكنية والتشطيبات الكاملة',
    );
    final project = (await repo.primaryActiveProject(client.id))!;
    final item = (await repo.watchActiveItems().first).first;
    for (var i = 1; i <= 28; i++) {
      await repo.insertTransaction(
        projectId: project.id,
        kind: i.isEven ? 'receive' : 'spend',
        amountPiastres: 1_000_000 * i,
        date: DateTime(2025, 6, i.clamp(1, 28)),
        method: 'cash',
        description: 'وصف طويل للبند رقم $i يشمل تفاصيل تشطيب ومواد ومصنعية',
        itemId: i.isOdd ? item.id : null,
        expenseType: i.isOdd ? 'materials' : null,
      );
    }
    final rows = await repo.transactionsForProject(project.id);
    final bounds = PeriodBounds.normalize(
      start: DateTime(2025, 6, 1),
      end: DateTime(2025, 6, 30),
    );
    final totals = LedgerMath.periodTotals(
      projectRows: rows,
      periodStart: bounds.start,
      periodEnd: bounds.end,
    );
    final copy = StatementPdfCopy(AppLocalizationsAr());
    expect(copy.periodRangeFromTo(bounds), contains('من'));
    expect(copy.periodRangeFromTo(bounds), contains('إلى'));

    final bytes = await PdfStatementService().buildClientStatement(
      client: client,
      totals: totals,
      periodSpend: rows.where((t) => t.kind == 'spend').toList(),
      periodReceive: rows.where((t) => t.kind == 'receive').toList(),
      itemNames: {item.id: item.name},
      supplierNames: const {},
      craftsmanNames: const {},
      bounds: bounds,
      copy: copy,
      unitAddress: unitAddress,
      sampleWatermark: true,
    );
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    expect(bytes.length, greaterThan(8000));

    final dir = Directory('test/artifacts');
    dir.createSync(recursive: true);
    final path = '${dir.path}/bnood-layout-client-synthetic.pdf';
    File(path).writeAsBytesSync(bytes);
    _mirrorArtifact('bnood-layout-client-synthetic.pdf', bytes);
  });

  test('synthetic supplier PDF with large negative-style balance row', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final supplier = await repo.createSupplier(name: 'مورد مواد وتشطيب باسم طويل جداً للاختبار');
    final client = await repo.createClient(name: 'عميل مشروع');
    final project = (await repo.primaryActiveProject(client.id))!;
    final item = (await repo.watchActiveItems().first).first;
    for (var i = 0; i < 18; i++) {
      await repo.insertTransaction(
        projectId: project.id,
        kind: 'spend',
        amountPiastres: 50_000_000 + i * 99_999,
        date: DateTime(2025, 7, 1 + (i % 20)),
        method: 'cash',
        description: 'دفعة مواد متعددة البنود $i',
        itemId: item.id,
        expenseType: 'materials',
        supplierId: supplier.id,
      );
    }
    final rows = await repo.supplierTransactions(supplier.id);
    final bounds = PeriodBounds.normalize(
      start: DateTime(2025, 7, 1),
      end: DateTime(2025, 7, 31),
    );
    final totals = SupplierPeriodMath.totals(supplierSpends: rows, bounds: bounds);
    final copy = StatementPdfCopy(AppLocalizationsAr());
    final bytes = await PdfStatementService().buildSupplierStatement(
      supplier: supplier,
      totals: totals,
      periodRows: rows.where((t) => bounds.containsLocalDate(t.date)).toList(),
      clientNamesByProjectId: {project.id: client.name},
      bounds: bounds,
      copy: copy,
    );
    expect(bytes.length, greaterThan(6000));
    final dir = Directory('test/artifacts');
    dir.createSync(recursive: true);
    final path = '${dir.path}/bnood-layout-supplier-synthetic.pdf';
    File(path).writeAsBytesSync(bytes);
    _mirrorArtifact('bnood-layout-supplier-synthetic.pdf', bytes);
  });
}

void _mirrorArtifact(String name, List<int> bytes) {
  try {
    final artifact = Directory('/opt/cursor/artifacts');
    if (artifact.existsSync()) {
      File('${artifact.path}/$name').writeAsBytesSync(bytes);
    }
  } catch (_) {}
}
