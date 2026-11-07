import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/brand/app_brand_lockup.dart';
import '../../core/database/database.dart';
import '../../core/formatting/display_digits.dart';
import '../../core/money/ledger_math.dart';
import '../../core/money/money_format.dart';
import '../../core/money/period_bounds.dart';
import '../../core/money/supplier_period_math.dart';
import '../../core/pdf/pdf_fonts.dart';
import 'statement_grouping.dart';
import 'statement_movement_text.dart';
import 'statement_pdf_copy.dart';
import 'statement_period_logic.dart';

class PdfStatementService {
  static const _primary = PdfColor.fromInt(0xFF0D9B8A);
  static const _muted = PdfColor.fromInt(0xFF5C6B68);

  static pw.ImageProvider? _logo;
  static Future<pw.ImageProvider> _loadLogo() async {
    if (_logo != null) return _logo!;
    final data = await rootBundle.load(AppBrandPdfLogo.horizontalPrimaryPng);
    _logo = pw.MemoryImage(data.buffer.asUint8List());
    return _logo!;
  }

  Future<Uint8List> buildClientStatement({
    required Client client,
    required StatementPeriodTotals totals,
    required List<Transaction> periodSpend,
    required List<Transaction> periodReceive,
    required Map<String, String> itemNames,
    required Map<String, String> supplierNames,
    required Map<String, String> craftsmanNames,
    required PeriodBounds bounds,
    required StatementPdfCopy copy,
    String? unitAddress,
    DateTime? issuedAt,
    bool sampleWatermark = false,
  }) async {
    final fonts = await PdfFonts.load();
    final logo = await _loadLogo();
    final doc = pw.Document();
    final periodLabel = StatementPeriodLogic.formatPeriodRangeLabel(bounds);
    final issued = issuedAt ?? DateTime.now();
    final issueLabel = StatementMovementText.formatMovementDate(issued);
    final groups = groupSpendByItem(
      periodSpend: periodSpend,
      itemNames: itemNames,
      unspecifiedItemLabel: copy.l10n.clientDetailUnspecifiedItem,
    );
    final receiveSorted = List<Transaction>.from(periodReceive)..sort((a, b) => a.date.compareTo(b.date));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 40, 36, 48),
        theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
        textDirection: pw.TextDirection.rtl,
        header: (ctx) => _pageHeader(
          logo: logo,
          title: copy.clientHeading,
          name: client.name,
          isContinuation: ctx.pageNumber > 1,
        ),
        footer: (ctx) => _pageFooter(
          copy: copy,
          entityName: client.name,
          page: ctx.pageNumber,
          pages: ctx.pagesCount,
        ),
        build: (context) => [
          if (sampleWatermark)
            pw.Text(
              'عينة — SAMPLE',
              style: pw.TextStyle(color: _primary, fontWeight: pw.FontWeight.bold),
            ),
          pw.SizedBox(height: 6),
          pw.Text(client.name, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          if (unitAddress != null && unitAddress.trim().isNotEmpty)
            pw.Text(unitAddress, style: const pw.TextStyle(fontSize: 10, color: _muted)),
          pw.Text(copy.periodLabel(periodLabel), style: const pw.TextStyle(fontSize: 10)),
          pw.Text(copy.issuedLabel(issueLabel), style: const pw.TextStyle(fontSize: 10)),
          pw.Text(copy.currencyNote, style: const pw.TextStyle(fontSize: 9, color: _muted)),
          pw.SizedBox(height: 12),
          _clientSummaryStrip(copy, totals),
          pw.SizedBox(height: 8),
          pw.Text(
            copy.itemMaterialsLabor(
              MoneyFormat.formatPiastres(totals.materialsPiastres),
              MoneyFormat.formatPiastres(totals.laborPiastres),
            ),
            style: const pw.TextStyle(fontSize: 9),
          ),
          if (totals.openingBalancePiastres != 0 ||
              totals.closingBalancePiastres != totals.openingBalancePiastres + totals.periodReceivedPiastres - totals.periodSpentPiastres)
            pw.Text(
              copy.l10n.statementOpeningPeriodNet(
                MoneyFormat.formatPiastres(totals.openingBalancePiastres),
                MoneyFormat.formatPiastres(
                  totals.periodReceivedPiastres - totals.periodSpentPiastres,
                ),
              ),
              style: const pw.TextStyle(fontSize: 9, color: _muted),
            ),
          pw.SizedBox(height: 14),
          pw.Text(copy.receiptsTitle, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _primary)),
          pw.Text(copy.receiptsCaption, style: const pw.TextStyle(fontSize: 9, color: _muted)),
          pw.SizedBox(height: 6),
          if (receiveSorted.isEmpty)
            pw.Text(copy.emptyReceipts, style: const pw.TextStyle(fontSize: 10, color: _muted))
          else
            _movementTable(
              copy: copy,
              rows: receiveSorted,
              lineFor: (t) => _receiveLine(t, copy),
            ),
          for (final g in groups) ...[
            pw.SizedBox(height: 14),
            pw.Text(copy.itemTitle(g.itemName), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(copy.itemTotal(MoneyFormat.formatPiastres(g.spentPiastres)),
                style: const pw.TextStyle(fontSize: 10)),
            pw.Text(
              copy.itemMaterialsLabor(
                MoneyFormat.formatPiastres(g.materialsPiastres),
                MoneyFormat.formatPiastres(g.laborPiastres),
              ),
              style: const pw.TextStyle(fontSize: 9, color: _muted),
            ),
            pw.SizedBox(height: 4),
            _movementTable(
              copy: copy,
              rows: g.rows,
              lineFor: (t) => _spendLine(t, copy, supplierNames, craftsmanNames),
            ),
          ],
          pw.SizedBox(height: 16),
          pw.Text(
            copy.reconcileSpend(
              MoneyFormat.formatPiastres(totals.materialsPiastres),
              MoneyFormat.formatPiastres(totals.laborPiastres),
              MoneyFormat.formatPiastres(totals.periodSpentPiastres),
            ),
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.Text(
            copy.reconcileBalance(
              openingPrefix: totals.openingBalancePiastres != 0
                  ? '${copy.openingBalance} ${MoneyFormat.formatPiastres(totals.openingBalancePiastres)} + '
                  : '',
              received: MoneyFormat.formatPiastres(totals.periodReceivedPiastres),
              spent: MoneyFormat.formatPiastres(totals.periodSpentPiastres),
              closing: MoneyFormat.formatPiastres(totals.closingBalancePiastres),
            ),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          ),
        ],
      ),
    );
    return doc.save();
  }

  Future<Uint8List> buildSupplierStatement({
    required Supplier supplier,
    required SupplierPeriodTotals totals,
    required List<Transaction> periodRows,
    required Map<String, String> clientNamesByProjectId,
    required PeriodBounds bounds,
    required StatementPdfCopy copy,
    DateTime? issuedAt,
  }) async {
    final fonts = await PdfFonts.load();
    final logo = await _loadLogo();
    final doc = pw.Document();
    final periodLabel = StatementPeriodLogic.formatPeriodRangeLabel(bounds);
    final issued = issuedAt ?? DateTime.now();
    final issueLabel = StatementMovementText.formatMovementDate(issued);
    final sorted = List<Transaction>.from(periodRows)..sort((a, b) => a.date.compareTo(b.date));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 40, 36, 48),
        theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
        textDirection: pw.TextDirection.rtl,
        header: (ctx) => _pageHeader(
          logo: logo,
          title: copy.supplierHeading,
          name: supplier.name,
          isContinuation: ctx.pageNumber > 1,
        ),
        footer: (ctx) => _pageFooter(
          copy: copy,
          entityName: supplier.name,
          page: ctx.pageNumber,
          pages: ctx.pagesCount,
        ),
        build: (context) => [
          pw.Text(supplier.name, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text(copy.periodLabel(periodLabel), style: const pw.TextStyle(fontSize: 10)),
          pw.Text(copy.issuedLabel(issueLabel), style: const pw.TextStyle(fontSize: 10)),
          pw.Text(copy.currencyNote, style: const pw.TextStyle(fontSize: 9, color: _muted)),
          pw.SizedBox(height: 12),
          _summaryTable(copy, [
            (copy.openingBalance, totals.openingPaidPiastres),
            (copy.spentWord, totals.periodPaidPiastres),
            (copy.closingBalance, totals.closingPaidPiastres),
          ]),
          pw.SizedBox(height: 14),
          pw.Text(copy.paymentsTitle, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _primary)),
          pw.Text(copy.paymentsCaption, style: const pw.TextStyle(fontSize: 9, color: _muted)),
          pw.SizedBox(height: 6),
          if (sorted.isEmpty)
            pw.Text(copy.emptyPayments, style: const pw.TextStyle(fontSize: 10, color: _muted))
          else
            _movementTable(
              copy: copy,
              rows: sorted,
              lineFor: (t) {
                final client = clientNamesByProjectId[t.projectId] ?? '';
                final desc = t.description?.trim();
                final main = (desc != null && desc.isNotEmpty) ? desc : copy.l10n.materials;
                final sub = client.isNotEmpty ? '${copy.l10n.materials} · $client' : copy.l10n.materials;
                return (main, sub);
              },
            ),
        ],
      ),
    );
    return doc.save();
  }

  pw.Widget _pageHeader({
    required pw.ImageProvider logo,
    required String title,
    required String name,
    required bool isContinuation,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Image(logo, height: 28),
            if (isContinuation)
              pw.Text('تابع', style: const pw.TextStyle(fontSize: 9, color: _muted)),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _primary)),
        if (isContinuation)
          pw.Text(name, style: const pw.TextStyle(fontSize: 10, color: _muted)),
        pw.Divider(color: _primary, thickness: 0.5),
      ],
    );
  }

  pw.Widget _pageFooter({
    required StatementPdfCopy copy,
    required String entityName,
    required int page,
    required int pages,
  }) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300, thickness: 0.5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(entityName, style: const pw.TextStyle(fontSize: 8, color: _muted)),
            pw.Text(
              copy.pageFooter(
                DisplayDigits.formatInteger(page),
                DisplayDigits.formatInteger(pages),
              ),
              style: const pw.TextStyle(fontSize: 8, color: _muted),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _clientSummaryStrip(StatementPdfCopy copy, StatementPeriodTotals totals) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _summaryChip(copy.totalReceived, totals.periodReceivedPiastres, PdfColors.green),
        _summaryChip(copy.totalSpent, totals.periodSpentPiastres, PdfColors.red),
        _summaryChip(copy.closingLabel, totals.closingBalancePiastres, _primary),
      ],
    );
  }

  pw.Widget _summaryChip(String label, int piastres, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.symmetric(horizontal: 4),
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
            pw.SizedBox(height: 4),
            pw.Text(
              MoneyFormat.formatPiastres(piastres),
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _summaryTable(StatementPdfCopy copy, List<(String, int)> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        for (final r in rows)
          pw.TableRow(children: [
            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(r.$1)),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(MoneyFormat.formatPiastres(r.$2), textAlign: pw.TextAlign.left),
            ),
          ]),
      ],
    );
  }

  (String main, String sub) _receiveLine(Transaction t, StatementPdfCopy copy) {
    final main = StatementMovementText.primaryLine(t, copy.l10n);
    final sub = StatementMovementText.subtitle(t: t, l10n: copy.l10n);
    return (main, sub);
  }

  (String main, String sub) _spendLine(
    Transaction t,
    StatementPdfCopy copy,
    Map<String, String> supplierNames,
    Map<String, String> craftsmanNames,
  ) {
    final party = t.expenseType == 'labor'
        ? craftsmanNames[t.craftsmanId ?? '']
        : supplierNames[t.supplierId ?? ''];
    final main = StatementMovementText.primaryLine(t, copy.l10n);
    final sub = StatementMovementText.subtitle(t: t, l10n: copy.l10n, partyName: party);
    return (main, sub);
  }

  pw.Widget _movementTable({
    required StatementPdfCopy copy,
    required List<Transaction> rows,
    required (String, String) Function(Transaction) lineFor,
  }) {
    var no = 1;
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FixedColumnWidth(48),
        1: const pw.FlexColumnWidth(2.5),
        2: const pw.FixedColumnWidth(88),
        3: const pw.FixedColumnWidth(24),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE8F4F2)),
          children: [
            _cell(copy.tableDate, align: pw.TextAlign.center, bold: true),
            _cell(copy.tableDetail, bold: true),
            _cell(copy.tableAmount, align: pw.TextAlign.center, bold: true),
            _cell(copy.tableSerial, align: pw.TextAlign.center, bold: true),
          ],
        ),
        for (final t in rows)
          pw.TableRow(children: [
            _cell(StatementMovementText.formatMovementDate(t.date), align: pw.TextAlign.center),
            _detailCell(lineFor(t)),
            _cell(MoneyFormat.formatPiastres(t.amountPiastres), align: pw.TextAlign.center),
            _cell(DisplayDigits.formatInteger(no++), align: pw.TextAlign.center),
          ]),
      ],
    );
  }

  pw.Widget _detailCell((String main, String sub) lines) => pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(lines.$1, style: const pw.TextStyle(fontSize: 10)),
            pw.Text(lines.$2, style: const pw.TextStyle(fontSize: 8, color: _muted)),
          ],
        ),
      );

  pw.Widget _cell(String text, {pw.TextAlign align = pw.TextAlign.right, bool bold = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
          textAlign: align,
        ),
      );
}
