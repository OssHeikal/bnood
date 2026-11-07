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

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('بنود — كشف حساب عميل')),
          pw.Text(client.name,
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text(
              'الفترة: ${periodStart.day}/${periodStart.month}/${periodStart.year} - ${periodEnd.day}/${periodEnd.month}/${periodEnd.year}'),
          pw.SizedBox(height: 12),
          _summaryRow('رصيد أول المدة', totals.openingBalancePiastres),
          _summaryRow('وارد الفترة', totals.periodReceivedPiastres),
          _summaryRow('صادر الفترة', totals.periodSpentPiastres),
          _summaryRow('رصيد آخر المدة', totals.closingBalancePiastres),
          _summaryRow('خامات', totals.materialsPiastres),
          _summaryRow('شغل يد', totals.laborPiastres),
          pw.SizedBox(height: 16),
          pw.Text('المصروفات حسب البند',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ..._groupedExpenses(periodSpend, itemNames),
          pw.SizedBox(height: 16),
          pw.Text('الإيصالات',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...periodReceive.map((t) => pw.Text(
              '${MoneyFormat.formatPiastres(t.amountPiastres)} — ${t.date.day}/${t.date.month}')),
        ],
      ),
    );
    return doc.save();
  }

  pw.Widget _summaryRow(String label, int piastres) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(MoneyFormat.formatPiastres(piastres)),
        ],
      ),
    );
  }

  List<pw.Widget> _groupedExpenses(
      List<Transaction> spend, Map<String, String> itemNames) {
    final byItem = <String, List<Transaction>>{};
    for (final t in spend) {
      final id = t.itemId ?? 'unknown';
      byItem.putIfAbsent(id, () => []).add(t);
    }
    final widgets = <pw.Widget>[];
    var no = 1;
    for (final entry in byItem.entries) {
      widgets.add(pw.Text(itemNames[entry.key] ?? entry.key,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
      for (final t in entry.value) {
        widgets.add(
          pw.Text(
              '$no | ${MoneyFormat.formatPiastres(t.amountPiastres)} | ${t.description ?? ''} | ${t.date.day}/${t.date.month}'),
        );
        no++;
      }
    }
    return widgets;
  }
}
