import 'package:bnood/l10n/app_localizations.dart';

/// Localized strings for statement PDF layout (AR/EN).
class StatementPdfCopy {
  const StatementPdfCopy(this.l10n);

  final AppLocalizations l10n;

  String get clientHeading => l10n.statementClientHeading;
  String get supplierHeading => l10n.statementSupplierHeading;
  String periodLabel(String label) => l10n.statementPeriodDisplay(label);
  String issuedLabel(String date) => l10n.statementIssuedOn(date);
  String get currencyNote => l10n.statementCurrencyNote;
  String get totalReceived => l10n.statementTotalReceived;
  String get totalSpent => l10n.statementTotalSpent;
  String get closingLabel => l10n.statementClosingLabel;
  String get openingBalance => l10n.openingBalance;
  String get closingBalance => l10n.closingBalance;
  String get materials => l10n.materials;
  String get labor => l10n.labor;
  String get receiptsTitle => l10n.statementReceiptsSectionTitle;
  String get receiptsCaption => l10n.statementReceiptsSectionCaption;
  String get emptyReceipts => l10n.statementEmptyReceipts;
  String get paymentsTitle => l10n.statementSupplierPaymentsTitle;
  String get paymentsCaption => l10n.statementSupplierPaymentsCaption;
  String get emptyPayments => l10n.statementEmptyPayments;
  String itemTitle(String name) => l10n.statementItemSectionTitle(name);
  String itemTotal(String total) => l10n.statementItemSectionTotal(total);
  String itemMaterialsLabor(String materials, String labor) =>
      l10n.statementItemMaterialsLabor(materials, labor);
  String reconcileSpend(String materials, String labor, String spent) =>
      l10n.statementReconcileSpend(materials, labor, spent);
  String reconcileBalance({
    required String openingPrefix,
    required String received,
    required String spent,
    required String closing,
  }) =>
      l10n.statementReconcileBalance(openingPrefix, received, spent, closing);
  String get tableSerial => l10n.statementTableSerial;
  String get tableAmount => l10n.statementTableAmount;
  String get tableDetail => l10n.statementTableDetail;
  String get tableDate => l10n.date;
  String pageFooter(String page, String pages) => l10n.statementPageFooter(page, pages);
  String get receivedWord => l10n.received;
  String get spentWord => l10n.spent;
}
