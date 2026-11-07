import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/database/database.dart';
import '../../core/money/ledger_math.dart';
import '../../core/money/money_format.dart';
import '../../core/money/period_bounds.dart';
import '../../core/money/supplier_period_math.dart';
import '../../core/pdf/pdf_fonts.dart';

class PdfStatementService {
  Future<Uint8List> buildClientStatement({
    required Client client,
    required StatementPeriodTotals totals,
    required List<Transaction> periodSpend,
    required List<Transaction> periodReceive,
    required Map<String, String> itemNames,
    required PeriodBounds bounds,
    DateTime? issuedAt,
    bool sampleWatermark = false,
  }) async {
    final fonts = await PdfFonts.load();
    final doc = pw.Document();
    final periodLabel =
        '${bounds.start.day}/${bounds.start.month}/${bounds.start.year} — '
        '${bounds.end.day}/${bounds.end.month}/${bounds.end.year}';
    final issued = issuedAt ?? DateTime.now();
    final issueLabel =
        '${issued.day}/${issued.month}/${issued.year}';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          if (sampleWatermark)
            pw.Text(
              'عينة — SAMPLE',
              style: pw.TextStyle(
                  color: PdfColors.teal700, fontWeight: pw.FontWeight.bold),
            ),
          pw.Text('بنود',
              style:
                  pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.Text('كشف حساب عميل'),
          pw.SizedBox(height: 6),
          pw.Text(client.name,
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('الفترة: $periodLabel'),
          pw.Text('تاريخ الإصدار: $issueLabel'),
          pw.Text(
            'رصيد أول + قبض − صرف = رصيد آخر',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 10),
          _summaryTable([
            ('رصيد أول المدة', totals.openingBalancePiastres),
            ('قبض الفترة', totals.periodReceivedPiastres),
            ('صرف الفترة', totals.periodSpentPiastres),
            ('رصيد آخر المدة', totals.closingBalancePiastres),
            ('خامات الفترة', totals.materialsPiastres),
            ('مصنعية الفترة', totals.laborPiastres),
          ]),
          pw.SizedBox(height: 14),
          pw.Text('مصروفات الفترة حسب البند',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ..._groupedExpenseTables(periodSpend, itemNames),
          pw.SizedBox(height: 14),
          pw.Text('إيصالات الاستلام (منفصلة عن البنود)',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          _movementTable(periodReceive, includeType: false),
        ],
      ),
    );
    return doc.save();
  }

  Future<Uint8List> buildSupplierStatement({
    required Supplier supplier,
    required SupplierPeriodTotals totals,
    required List<Transaction> periodRows,
    required PeriodBounds bounds,
    DateTime? issuedAt,
  }) async {
    final fonts = await PdfFonts.load();
    final doc = pw.Document();
    final periodLabel =
        '${bounds.start.day}/${bounds.start.month}/${bounds.start.year} — '
        '${bounds.end.day}/${bounds.end.month}/${bounds.end.year}';
    final issued = issuedAt ?? DateTime.now();
    final issueLabel =
        '${issued.day}/${issued.month}/${issued.year}';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          pw.Text('بنود — كشف مورد',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text(supplier.name),
          pw.Text('الفترة: $periodLabel'),
          pw.Text('تاريخ الإصدار: $issueLabel'),
          _summaryTable([
            ('مدفوع قبل الفترة', totals.openingPaidPiastres),
            ('مدفوع خلال الفترة', totals.periodPaidPiastres),
            ('إجمالي مدفوع', totals.closingPaidPiastres),
          ]),
          pw.SizedBox(height: 12),
          _movementTable(periodRows, includeType: true),
        ],
      ),
    );
    return doc.save();
  }

  pw.Widget _summaryTable(List<(String, int)> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        for (final r in rows)
          pw.TableRow(children: [
            pw.Padding(
                padding: const pw.EdgeInsets.all(6), child: pw.Text(r.$1)),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(MoneyFormat.formatPiastres(r.$2),
                  textAlign: pw.TextAlign.left),
            ),
          ]),
      ],
    );
  }

  List<pw.Widget> _groupedExpenseTables(
    List<Transaction> spend,
    Map<String, String> itemNames,
  ) {
    final byItem = <String, List<Transaction>>{};
    for (final t in spend) {
      byItem.putIfAbsent(t.itemId ?? 'unknown', () => []).add(t);
    }
    final out = <pw.Widget>[];
    for (final entry in byItem.entries) {
      final mats =
          entry.value.where((t) => t.expenseType == 'materials').toList();
      final lab = entry.value.where((t) => t.expenseType == 'labor').toList();
      final itemTotal =
          entry.value.fold<int>(0, (s, t) => s + t.amountPiastres);
      final matTotal =
          mats.fold<int>(0, (s, t) => s + t.amountPiastres);
      final labTotal = lab.fold<int>(0, (s, t) => s + t.amountPiastres);
      out.add(pw.SizedBox(height: 8));
      out.add(pw.Text(
        '${itemNames[entry.key] ?? entry.key} — '
        'إجمالي ${MoneyFormat.formatPiastres(itemTotal)} · '
        'خامات ${MoneyFormat.formatPiastres(matTotal)} · '
        'مصنعية ${MoneyFormat.formatPiastres(labTotal)}',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ));
      if (mats.isNotEmpty) {
        out.add(pw.Text('خامات', style: const pw.TextStyle(fontSize: 11)));
        out.add(_movementTable(mats, includeType: true));
      }
      if (lab.isNotEmpty) {
        out.add(pw.Text('مصنعية', style: const pw.TextStyle(fontSize: 11)));
        out.add(_movementTable(lab, includeType: true));
      }
    }
    return out;
  }

  pw.Widget _movementTable(List<Transaction> rows,
      {required bool includeType}) {
    var no = 1;
    // Columns left→right: تاريخ | بيان | مبلغ | م → Arabic read order م | مبلغ | بيان | تاريخ.
    final table = pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FixedColumnWidth(56),
        1: const pw.FlexColumnWidth(),
        2: const pw.FixedColumnWidth(90),
        3: const pw.FixedColumnWidth(28),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _cell('تاريخ', align: pw.TextAlign.center),
            _cell('بيان'),
            _cell('مبلغ', align: pw.TextAlign.center),
            _cell('م', align: pw.TextAlign.center),
          ],
        ),
        for (final t in rows)
          pw.TableRow(children: [
            _cell('${t.date.day}/${t.date.month}', align: pw.TextAlign.center),
            _cell(includeType
                ? (t.description ?? t.expenseType ?? '')
                : (t.description ?? '')),
            _cell(MoneyFormat.formatPiastres(t.amountPiastres),
                align: pw.TextAlign.center),
            _cell('${no++}', align: pw.TextAlign.center),
          ]),
      ],
    );
    return table;
  }

  pw.Widget _cell(String text, {pw.TextAlign align = pw.TextAlign.right}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(text,
            style: const pw.TextStyle(fontSize: 10), textAlign: align),
      );
}
