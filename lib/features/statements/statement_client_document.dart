import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/database/database.dart';
import '../../core/money/ledger_math.dart';
import '../../core/money/money_format.dart';
import '../../core/widgets/app_amount.dart';
import '../../core/widgets/app_card.dart';
import 'statement_grouping.dart';
import 'statement_movement_list.dart';
import 'statement_reconcile_card.dart';

class StatementClientDocument extends StatelessWidget {
  const StatementClientDocument({
    super.key,
    required this.clientName,
    this.unitAddress,
    required this.totals,
    required this.periodReceive,
    required this.periodSpend,
    required this.itemNames,
    required this.supplierNames,
    required this.craftsmanNames,
    required this.localeCode,
    required this.showPeriodOpening,
  });

  final String clientName;
  final String? unitAddress;
  final StatementPeriodTotals totals;
  final List<Transaction> periodReceive;
  final List<Transaction> periodSpend;
  final Map<String, String> itemNames;
  final Map<String, String> supplierNames;
  final Map<String, String> craftsmanNames;
  final String localeCode;
  final bool showPeriodOpening;

  String get _moneyLocale => localeCode == 'ar' ? 'ar_EG' : 'en_US';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;
    final groups = groupSpendByItem(
      periodSpend: periodSpend,
      itemNames: itemNames,
      unspecifiedItemLabel: l10n.clientDetailUnspecifiedItem,
    );
    final receives = List<Transaction>.from(periodReceive)..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(clientName, style: text.pageTitle),
        if (unitAddress != null && unitAddress!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(unitAddress!, style: text.supporting.copyWith(color: colors.onSurfaceMuted)),
          ),
        const SizedBox(height: AppSize.spaceMD),
        Row(
          children: [
            Expanded(
              child: _statCard(context, l10n.statementTotalReceived, totals.periodReceivedPiastres, AppCardPreset.statReceive),
            ),
            const SizedBox(width: AppSize.spaceSM),
            Expanded(
              child: _statCard(context, l10n.statementTotalSpent, totals.periodSpentPiastres, AppCardPreset.statSpend),
            ),
            const SizedBox(width: AppSize.spaceSM),
            Expanded(
              child: _statCard(
                context,
                showPeriodOpening ? l10n.statementClosingEndOfPeriod : l10n.statementClosingLabel,
                totals.closingBalancePiastres,
                AppCardPreset.statRemaining,
              ),
            ),
          ],
        ),
        if (showPeriodOpening) ...[
          const SizedBox(height: AppSize.spaceSM),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceMD, vertical: AppSize.spaceSM),
            child: Row(
              children: [
                Expanded(
                  child: Text(l10n.openingBalance, style: text.label),
                ),
                AppAmount(
                  piastres: totals.openingBalancePiastres,
                  localeCode: localeCode,
                  size: AppAmountSize.small,
                  role: AppAmountRole.remaining,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSize.spaceLG),
        _sectionTitle(context, l10n.statementReceiptsSectionTitle, l10n.statementReceiptsSectionCaption),
        if (receives.isEmpty)
          Text(l10n.statementEmptyReceipts, style: text.caption.copyWith(color: colors.onSurfaceMuted))
        else
          StatementMovementList(
            rows: receives,
            l10n: l10n,
            localeCode: localeCode,
          ),
        for (final g in groups) ...[
          const SizedBox(height: AppSize.spaceLG),
          _itemGroupHeader(context, g, l10n),
          const SizedBox(height: AppSize.spaceSM),
          StatementMovementList(
            rows: g.rows,
            l10n: l10n,
            localeCode: localeCode,
            partyNameFor: (t) => t.expenseType == 'labor'
                ? craftsmanNames[t.craftsmanId ?? '']
                : supplierNames[t.supplierId ?? ''],
          ),
        ],
        const SizedBox(height: AppSize.spaceLG),
        ClientStatementReconcileCard(
          totals: totals,
          localeCode: localeCode,
          showPeriodOpening: showPeriodOpening,
        ),
      ],
    );
  }

  Widget _statCard(BuildContext context, String label, int piastres, AppCardPreset preset) {
    final text = context.text;
    return AppCard(
      preset: preset,
      padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceSM, vertical: AppSize.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: text.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSize.spaceXS),
          AppAmount(piastres: piastres, localeCode: localeCode, size: AppAmountSize.small),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, String caption) {
    final colors = context.colors;
    final text = context.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: text.sectionTitle),
        Text(caption, style: text.caption.copyWith(color: colors.onSurfaceMuted)),
        const SizedBox(height: AppSize.spaceSM),
      ],
    );
  }

  Widget _itemGroupHeader(BuildContext context, ItemStatementGroup g, AppLocalizations l10n) {
    final text = context.text;
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(AppSize.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(l10n.statementItemSectionTitle(g.itemName), style: text.sectionTitle),
              ),
              AppAmount(
                piastres: g.spentPiastres,
                localeCode: localeCode,
                size: AppAmountSize.small,
                role: AppAmountRole.spend,
              ),
            ],
          ),
          const SizedBox(height: AppSize.spaceSM),
          _breakdownRow(context, l10n.materials, g.materialsPiastres),
          _breakdownRow(context, l10n.labor, g.laborPiastres),
        ],
      ),
    );
  }

  Widget _breakdownRow(BuildContext context, String label, int piastres) {
    final text = context.text;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Text(label, style: text.supporting),
          const Spacer(),
          Text(
            MoneyFormat.formatPiastres(piastres, locale: _moneyLocale),
            style: text.bodyEmphasis,
          ),
        ],
      ),
    );
  }
}
