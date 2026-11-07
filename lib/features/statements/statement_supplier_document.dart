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
          padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceMD, vertical: AppSize.spaceSM),
          child: Column(
            children: [
              _summaryRow(context, l10n.openingBalance, totals.openingPaidPiastres),
              const Divider(height: 1),
              _summaryRow(context, l10n.spent, totals.periodPaidPiastres, role: AppAmountRole.spend),
              const Divider(height: 1),
              _summaryRow(context, l10n.closingBalance, totals.closingPaidPiastres, emphasized: true),
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

  Widget _summaryRow(
    BuildContext context,
    String label,
    int piastres, {
    AppAmountRole role = AppAmountRole.neutral,
    bool emphasized = false,
  }) {
    final text = context.text;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSize.spaceSM),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: emphasized ? text.sectionTitle : text.body,
            ),
          ),
          AppAmount(
            piastres: piastres,
            localeCode: localeCode,
            size: emphasized ? AppAmountSize.medium : AppAmountSize.small,
            role: role,
          ),
        ],
      ),
    );
  }
}
