import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../core/config/theme/app_size.dart';
import '../../core/money/ledger_math.dart';
import '../../core/money/supplier_period_math.dart';
import '../../core/widgets/app_amount.dart';
import '../../core/widgets/app_card.dart';

class ClientStatementReconcileCard extends StatelessWidget {
  const ClientStatementReconcileCard({
    super.key,
    required this.totals,
    required this.localeCode,
    required this.showPeriodOpening,
  });

  final StatementPeriodTotals totals;
  final String localeCode;
  final bool showPeriodOpening;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.statementReconcileSectionTitle, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSize.spaceSM),
          if (showPeriodOpening)
            _line(context, l10n.openingBalance, totals.openingBalancePiastres),
          _line(context, l10n.received, totals.periodReceivedPiastres, role: AppAmountRole.receive),
          _line(context, l10n.spent, totals.periodSpentPiastres, role: AppAmountRole.spend),
          const Divider(height: AppSize.spaceMD),
          _line(
            context,
            l10n.closingBalance,
            totals.closingBalancePiastres,
            role: AppAmountRole.remaining,
            emphasized: true,
          ),
        ],
      ),
    );
  }

  Widget _line(
    BuildContext context,
    String label,
    int piastres, {
    AppAmountRole role = AppAmountRole.neutral,
    bool emphasized = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: emphasized
                  ? Theme.of(context).textTheme.titleSmall
                  : Theme.of(context).textTheme.bodyMedium,
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

class SupplierStatementReconcileCard extends StatelessWidget {
  const SupplierStatementReconcileCard({
    super.key,
    required this.totals,
    required this.localeCode,
  });

  final SupplierPeriodTotals totals;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.statementReconcileSectionTitle, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSize.spaceSM),
          _line(context, l10n.openingBalance, totals.openingPaidPiastres),
          _line(context, l10n.spent, totals.periodPaidPiastres, role: AppAmountRole.spend),
          const Divider(height: AppSize.spaceMD),
          _line(
            context,
            l10n.closingBalance,
            totals.closingPaidPiastres,
            role: AppAmountRole.spend,
            emphasized: true,
          ),
        ],
      ),
    );
  }

  Widget _line(
    BuildContext context,
    String label,
    int piastres, {
    AppAmountRole role = AppAmountRole.neutral,
    bool emphasized = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: emphasized
                  ? Theme.of(context).textTheme.titleSmall
                  : Theme.of(context).textTheme.bodyMedium,
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
