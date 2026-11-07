import 'dart:io';

import 'package:bnood/core/database/database.dart';
import 'package:bnood/core/money/ledger_math.dart';
import 'package:bnood/core/money/period_bounds.dart';
import 'package:bnood/features/statements/pdf_statement_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'), null);
  });

  test('generate SAMPLE client PDF artifact with Arabic glyphs (offline fonts)',
      () async {
    final bounds = PeriodBounds.normalize(
      start: DateTime(2025, 6, 1),
      end: DateTime(2025, 6, 30),
    );
    final client = Client(
      id: 'c',
      workspaceId: 'w',
      name: 'أحمد محمد — عميل تجريبي',
      phone: '01001234567',
      archivedAt: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final itemA = 'item-a';
    final itemB = 'item-b';
    final spends = [
      _spend(150000, DateTime(2025, 6, 5), itemA, 'materials', 'حديد تسليح'),
      _spend(80000, DateTime(2025, 6, 12), itemA, 'labor', 'أعمال محارة'),
      _spend(120000, DateTime(2025, 6, 18), itemB, 'materials', 'سيراميك حمام'),
      _spend(60000, DateTime(2025, 6, 25), itemB, 'labor', 'تركيب'),
      _spend(50000, DateTime(2025, 6, 28), itemB, 'materials',
          'شيء إضافي لصفحة ثانية '.padRight(40, '·')),
    ];
    final receives = [
      _recv(500000, DateTime(2025, 5, 20)),
      _recv(200000, DateTime(2025, 6, 3)),
      _recv(100000, DateTime(2025, 6, 20)),
    ];
    final rows = [...receives, ...spends];
    final totals = LedgerMath.periodTotals(
      projectRows: rows,
      periodStart: bounds.start,
      periodEnd: bounds.end,
    );
    expect(
      totals.closingBalancePiastres,
      totals.openingBalancePiastres +
          totals.periodReceivedPiastres -
          totals.periodSpentPiastres,
    );

    final bytes = await PdfStatementService().buildClientStatement(
      client: client,
      totals: totals,
      periodSpend: spends,
      periodReceive:
          receives.where((t) => bounds.containsLocalDate(t.date)).toList(),
      itemNames: {
        itemA: 'محارة',
        itemB: 'سيراميك وحمامات',
      },
      bounds: bounds,
      issuedAt: DateTime(2025, 11, 7),
      sampleWatermark: true,
    );

    final dir = Directory('/opt/cursor/artifacts');
    if (!await dir.exists()) await dir.create(recursive: true);
    final pdfPath = '${dir.path}/bnood-sample-statement.pdf';
    await File(pdfPath).writeAsBytes(bytes);
    expect(await File(pdfPath).length(), greaterThan(2000));

    final strings = String.fromCharCodes(bytes);
    expect(strings.contains('Font'), isTrue);
    expect(bytes.length, greaterThan(3000));
  });
}

Transaction _spend(
        int amount, DateTime d, String itemId, String type, String desc) =>
    Transaction(
      id: '$amount$d',
      workspaceId: 'w',
      projectId: 'p',
      kind: 'spend',
      amountPiastres: amount,
      date: d,
      method: 'transfer',
      description: desc,
      receiptImagePath: null,
      itemId: itemId,
      expenseType: type,
      supplierId: 'sup',
      craftsmanId: type == 'labor' ? 'craft' : null,
      createdAt: d,
      updatedAt: d,
    );

Transaction _recv(int amount, DateTime d) => Transaction(
      id: 'r$amount',
      workspaceId: 'w',
      projectId: 'p',
      kind: 'receive',
      amountPiastres: amount,
      date: d,
      method: 'cash',
      description: 'دفعة استلام',
      receiptImagePath: null,
      itemId: null,
      expenseType: null,
      supplierId: null,
      craftsmanId: null,
      createdAt: d,
      updatedAt: d,
    );
