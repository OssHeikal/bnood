import 'package:flutter/material.dart';

import '../../../../core/services/config/extensions/num_extensions.dart';
import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/domain/money/remote_money_units.dart';
import '../../../../core/ui/widgets/app_amount.dart';
import '../../../../core/ui/widgets/app_card.dart';
import 'package:bnood/features/providers/presentation/models/provider_detail_agreement_totals.dart';
import 'package:bnood/features/providers/presentation/widgets/provider_detail_metric_stack.dart';

class ProviderDetailTotalsCards extends StatelessWidget {
  const ProviderDetailTotalsCards({
    super.key,
    required this.totals,
    required this.agreedLabel,
    required this.paidLabel,
    required this.remainingLabel,
    required this.localeCode,
    this.hideMoney = false,
  });

  final ProviderAgreementTotals totals;
  final String agreedLabel;
  final String paidLabel;
  final String remainingLabel;
  final String localeCode;
  final bool hideMoney;

  @override
  Widget build(BuildContext context) {
    if (hideMoney) return const SizedBox.shrink();
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (totals.agreedMinor != null) ...[
            Expanded(
              child: ProviderDetailTotalCard(
                key: const Key('provider_detail_total_agreed'),
                label: agreedLabel,
                piastres: totals.agreedMinor!,
                role: AppAmountRole.neutral,
                localeCode: localeCode,
              ),
            ),
            AppSize.spaceSM.gap,
          ],
          Expanded(
            child: ProviderDetailTotalCard(
              key: const Key('provider_detail_total_paid'),
              label: paidLabel,
              piastres: totals.paidMinor,
              role: AppAmountRole.spend,
              localeCode: localeCode,
            ),
          ),
          if (totals.remainingMinor != null) ...[
            AppSize.spaceSM.gap,
            Expanded(
              child: ProviderDetailTotalCard(
                key: const Key('provider_detail_total_remaining'),
                label: remainingLabel,
                piastres: totals.remainingMinor!,
                role: AppAmountRole.remaining,
                localeCode: localeCode,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ProviderDetailTotalCard extends StatelessWidget {
  const ProviderDetailTotalCard({
    super.key,
    required this.label,
    required this.piastres,
    required this.role,
    required this.localeCode,
    this.minorPerMajor = RemoteMoneyUnits.minorPerMajor,
  });

  final String label;
  final int piastres;
  final AppAmountRole role;
  final String localeCode;
  final int minorPerMajor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSize.spaceMD),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: ProviderDetailMetricStack(
          label: label,
          piastres: piastres,
          role: role,
          localeCode: localeCode,
          minorPerMajor: minorPerMajor,
        ),
      ),
    );
  }
}
