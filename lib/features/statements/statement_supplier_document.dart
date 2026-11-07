import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/database/database.dart';
import '../../core/money/supplier_period_math.dart';
import '../../core/widgets/app_amount.dart';
import '../../core/widgets/app_card.dart';
import 'statement_movement_list.dart';
import 'statement_reconcile_card.dart';
import 'statement_summary_widgets.dart';

class StatementSupplierDocument extends StatelessWidget {
  const StatementSupplierDocument({
    super.key,
    required this.supplierName,
    required this.totals,
    required this.periodRows,
    required this.clientNamesByProjectId,
    required this.localeCode,
    required this.showPeriodOpening,
  });

  final String supplierName;
  final SupplierPeriodTotals totals;
  final List<Transaction> periodRows;
  final Map<String, String> clientNamesByProjectId;
  final String localeCode;
  final bool showPeriodOpening;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;
    final rows = List<Transaction>.from(periodRows)..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(supplierName, style: text.pageTitle),
        const SizedBox(height: AppSize.spaceMD),
        AppCard(
          key: const Key('statement_supplier_summary'),
          padding: statementOpeningBalancePadding,
          child: Column(
            children: [
              StatementLabeledAmountRow(
                rowKey: const Key('statement_supplier_opening'),
                label: l10n.openingBalance,
                piastres: totals.openingPaidPiastres,
                localeCode: localeCode,
              ),
              Divider(height: 1, color: colors.outlineSubtle),
              StatementLabeledAmountRow(
                rowKey: const Key('statement_supplier_spent'),
                label: l10n.spent,
                piastres: totals.periodPaidPiastres,
                localeCode: localeCode,
                role: AppAmountRole.spend,
              ),
              Divider(height: 1, color: colors.outlineSubtle),
              StatementLabeledAmountRow(
                rowKey: const Key('statement_supplier_closing'),
                label: l10n.closingBalance,
                piastres: totals.closingPaidPiastres,
                localeCode: localeCode,
                emphasized: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSize.spaceLG),
        Text(l10n.statementSupplierPaymentsTitle, style: text.sectionTitle),
        Text(
          l10n.statementSupplierPaymentsCaption,
          style: text.caption.copyWith(color: colors.onSurfaceMuted),
        ),
        const SizedBox(height: AppSize.spaceSM),
        if (rows.isEmpty)
          Text(l10n.statementEmptyPayments, style: text.caption.copyWith(color: colors.onSurfaceMuted))
        else
          StatementMovementList(
            rows: rows,
            l10n: l10n,
            localeCode: localeCode,
            partyNameFor: (t) => clientNamesByProjectId[t.projectId],
          ),
        if (showPeriodOpening && totals.openingPaidPiastres != 0) ...[
          const SizedBox(height: AppSize.spaceMD),
          SupplierStatementReconcileCard(totals: totals, localeCode: localeCode),
        ],
      ],
    );
  }

}
