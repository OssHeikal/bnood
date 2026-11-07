import 'dart:typed_data';

import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/database/database.dart';
import '../../core/money/ledger_math.dart';
import '../../core/money/money_format.dart';

class PdfStatementService {
  Future<Uint8List> buildClientStatement({
    required Client client,
    required StatementPeriodTotals totals,
    required List<Transaction> periodSpend,
    required List<Transaction> periodReceive,
    required Map<String, String> itemNames,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();
    final theme = pw.ThemeData.withFont(base: font, bold: fontBold);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          pw.Text('بنود',
              style:
                  pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.Text('كشف حساب عميل', style: const pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 8),
          pw.Text(client.name,
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text(
            'الفترة: ${periodStart.day}/${periodStart.month}/${periodStart.year} — '
            '${periodEnd.day}/${periodEnd.month}/${periodEnd.year}',
          ),
          pw.SizedBox(height: 12),
          _summaryTable([
            ('رصيد أول المدة', totals.openingBalancePiastres),
            ('وارد الفترة', totals.periodReceivedPiastres),
            ('صادر الفترة', totals.periodSpentPiastres),
            ('رصيد آخر المدة', totals.closingBalancePiastres),
            ('خامات', totals.materialsPiastres),
            ('شغل يد', totals.laborPiastres),
          ]),
          pw.SizedBox(height: 16),
          pw.Text('مصروفات الفترة حسب البند',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ..._groupedExpenseTables(periodSpend, itemNames),
          pw.SizedBox(height: 16),
          pw.Text('إيصالات الاستلام (منفصلة)',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          _movementTable(periodReceive, includeType: false),
        ],
      ),
    );
    return doc.save();
  }

  Future<Uint8List> buildSupplierStatement({
    required Supplier supplier,
    required int openingPiastres,
    required int periodPiastres,
    required int closingPiastres,
    required List<Transaction> rows,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();
    final periodRows = rows.where((t) {
      return !t.date.isBefore(
              DateTime(periodStart.year, periodStart.month, periodStart.day)) &&
          !t.date.isAfter(DateTime(
              periodEnd.year, periodEnd.month, periodEnd.day, 23, 59, 59));
    }).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          pw.Text('بنود — كشف مورد',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text(supplier.name),
          _summaryTable([
            ('رصيد سابق', openingPiastres),
            ('مدفوعات الفترة', periodPiastres),
            ('إجمالي', closingPiastres),
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
      List<Transaction> spend, Map<String, String> itemNames) {
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
      out.add(pw.SizedBox(height: 8));
      out.add(pw.Text(
        '${itemNames[entry.key] ?? entry.key} — ${MoneyFormat.formatPiastres(itemTotal)}',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ));
      if (mats.isNotEmpty) {
        out.add(pw.Text('خامات', style: pw.TextStyle(fontSize: 11)));
        out.add(_movementTable(mats, includeType: true));
      }
      if (lab.isNotEmpty) {
        out.add(pw.Text('شغل يد', style: pw.TextStyle(fontSize: 11)));
        out.add(_movementTable(lab, includeType: true));
      }
    }
    return out;
  }

  pw.Widget _movementTable(List<Transaction> rows,
      {required bool includeType}) {
    var no = 1;
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FixedColumnWidth(28),
        1: const pw.FixedColumnWidth(90),
        2: const pw.FlexColumnWidth(),
        3: const pw.FixedColumnWidth(56),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _cell('م'),
            _cell('المبلغ'),
            _cell('الوصف'),
            _cell('التاريخ'),
          ],
        ),
        for (final t in rows)
          pw.TableRow(children: [
            _cell('${no++}'),
            _cell(MoneyFormat.formatPiastres(t.amountPiastres)),
            _cell(includeType
                ? (t.description ?? t.expenseType ?? '')
                : (t.description ?? '')),
            _cell('${t.date.day}/${t.date.month}'),
          ]),
      ],
    );
  }

  pw.Widget _cell(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
      );
}
