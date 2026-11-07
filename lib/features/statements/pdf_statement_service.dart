import 'package:flutter/foundation.dart';
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
class PdfStatementService {
  static const _primary = PdfColor.fromInt(0xFF0D9B8A);
  static const _muted = PdfColor.fromInt(0xFF5C6B68);
  static const _surface = PdfColor.fromInt(0xFFF4F7F6);
  static const _ink = PdfColor.fromInt(0xFF1A2422);

  @visibleForTesting
  static const dateColumnWidth = 78.0;

  @visibleForTesting
  static const amountColumnWidth = 102.0;

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
          pw.SizedBox(height: 4),
          _partyTitle(client.name, unitAddress: unitAddress),
          pw.SizedBox(height: 8),
          _periodMeta(copy, bounds: bounds, issuedLabel: copy.issuedLabel(issueLabel)),
          pw.SizedBox(height: 14),
          _clientSummaryStrip(copy, totals),
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
          pw.SizedBox(height: 18),
          _clientReconcileSection(copy, totals),
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
          _partyTitle(supplier.name),
          pw.SizedBox(height: 8),
          _periodMeta(copy, bounds: bounds, issuedLabel: copy.issuedLabel(issueLabel)),
          pw.SizedBox(height: 14),
          pw.Text(copy.reconcileSectionTitle, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _primary, fontSize: 11)),
          pw.SizedBox(height: 6),
          _summaryTable(copy, [
            (copy.openingBalance, totals.openingPaidPiastres),
            (copy.spentWord, totals.periodPaidPiastres),
            (copy.closingBalance, totals.closingPaidPiastres),
          ], emphasizeLast: true),
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
            pw.Image(logo, height: 36),
            if (isContinuation)
              pw.Text('تابع', style: const pw.TextStyle(fontSize: 9, color: _muted)),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _primary)),
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

  pw.Widget _partyTitle(String name, {String? unitAddress}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(name, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _ink)),
        if (unitAddress != null && unitAddress.trim().isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2),
            child: pw.Text(unitAddress.trim(), style: const pw.TextStyle(fontSize: 10, color: _muted)),
          ),
      ],
    );
  }

  pw.Widget _periodMeta(
    StatementPdfCopy copy, {
    required PeriodBounds bounds,
    required String issuedLabel,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.RichText(
              text: pw.TextSpan(
                children: _periodRangeSpans(copy, bounds),
                style: const pw.TextStyle(fontSize: 10, color: _ink),
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(issuedLabel, style: const pw.TextStyle(fontSize: 9, color: _muted)),
          pw.Text(copy.currencyNote, style: const pw.TextStyle(fontSize: 8, color: _muted)),
        ],
      ),
    );
  }

  List<pw.InlineSpan> _periodRangeSpans(StatementPdfCopy copy, PeriodBounds bounds) {
    final from = StatementMovementText.formatMovementDate(bounds.start);
    final to = StatementMovementText.formatMovementDate(bounds.end);
    final labelStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: _primary);
    final dateStyle = const pw.TextStyle(fontSize: 10, color: _ink);
    if (from == to) {
      return [
        pw.TextSpan(text: '${copy.periodFromLabel} ', style: labelStyle),
        pw.TextSpan(text: from, style: dateStyle),
      ];
    }
    return [
      pw.TextSpan(text: '${copy.periodFromLabel} ', style: labelStyle),
      pw.TextSpan(text: from, style: dateStyle),
      pw.TextSpan(text: '   ${copy.periodToLabel} ', style: labelStyle),
      pw.TextSpan(text: to, style: dateStyle),
    ];
  }

  pw.Widget _clientReconcileSection(StatementPdfCopy copy, StatementPeriodTotals totals) {
    final rows = <(String, int, bool)>[
      (copy.materials, totals.materialsPiastres, false),
      (copy.labor, totals.laborPiastres, false),
      (copy.spentWord, totals.periodSpentPiastres, false),
      if (totals.openingBalancePiastres != 0) (copy.openingBalance, totals.openingBalancePiastres, false),
      (copy.receivedWord, totals.periodReceivedPiastres, false),
      (copy.closingBalance, totals.closingBalancePiastres, true),
    ];
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(copy.reconcileSectionTitle, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _primary, fontSize: 11)),
        pw.SizedBox(height: 6),
        _summaryTable(copy, rows.map((r) => (r.$1, r.$2)).toList(), emphasizeLast: rows.last.$3),
      ],
    );
  }

  pw.Widget _summaryTable(StatementPdfCopy copy, List<(String, int)> rows, {bool emphasizeLast = false}) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FixedColumnWidth(amountColumnWidth),
      },
      children: [
        for (var i = 0; i < rows.length; i++)
          pw.TableRow(
            decoration: i.isEven ? null : const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFAFCFB)),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                child: pw.Text(
                  rows[i].$1,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: emphasizeLast && i == rows.length - 1 ? pw.FontWeight.bold : pw.FontWeight.normal,
                  ),
                ),
              ),
              _amountCell(MoneyFormat.formatPiastres(rows[i].$2), emphasized: emphasizeLast && i == rows.length - 1),
            ],
          ),
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
        0: const pw.FixedColumnWidth(dateColumnWidth),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FixedColumnWidth(amountColumnWidth),
        3: const pw.FixedColumnWidth(30),
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
            _dateCell(StatementMovementText.formatMovementDate(t.date)),
            _detailCell(lineFor(t)),
            _amountCell(MoneyFormat.formatPiastres(t.amountPiastres)),
            _serialCell(DisplayDigits.formatInteger(no++)),
          ]),
      ],
    );
  }

  pw.Widget _detailCell((String main, String sub) lines) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(lines.$1, style: const pw.TextStyle(fontSize: 10, color: _ink)),
            pw.SizedBox(height: 2),
            pw.Text(lines.$2, style: const pw.TextStyle(fontSize: 8, color: _muted)),
          ],
        ),
      );

  pw.Widget _dateCell(String text) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: pw.Directionality(
          textDirection: pw.TextDirection.ltr,
          child: pw.Text(
            text,
            maxLines: 1,
            style: const pw.TextStyle(fontSize: 10, color: _ink),
            textAlign: pw.TextAlign.center,
          ),
        ),
      );

  pw.Widget _amountCell(String text, {bool emphasized = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: pw.Directionality(
          textDirection: pw.TextDirection.ltr,
          child: pw.Text(
            text,
            maxLines: 1,
            style: pw.TextStyle(
              fontSize: emphasized ? 11 : 10,
              fontWeight: emphasized ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: _ink,
            ),
            textAlign: pw.TextAlign.right,
          ),
        ),
      );

  pw.Widget _serialCell(String text) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        child: pw.Directionality(
          textDirection: pw.TextDirection.ltr,
          child: pw.Text(
            text,
            maxLines: 1,
            style: const pw.TextStyle(fontSize: 9, color: _muted),
            textAlign: pw.TextAlign.center,
          ),
        ),
      );

  pw.Widget _cell(String text, {pw.TextAlign align = pw.TextAlign.right, bool bold = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
