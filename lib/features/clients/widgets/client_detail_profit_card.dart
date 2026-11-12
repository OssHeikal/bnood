import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/money/basis_points.dart';
import '../../../core/widgets/app_amount.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chevron.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../l10n/app_localizations.dart';

class ClientDetailProfitCard extends StatelessWidget {
  const ClientDetailProfitCard({
    super.key,
    required this.engineerBasisPoints,
    required this.estimatedProfitPiastres,
    required this.localeCode,
    required this.onEdit,
    this.mutationsEnabled = true,
    this.minorPerMajor = 100,
  });

  final int? engineerBasisPoints;
  final int? estimatedProfitPiastres;
  final String localeCode;
  final VoidCallback onEdit;
  final bool mutationsEnabled;
  final int minorPerMajor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;
    final percentCaption = engineerBasisPoints == null
        ? l10n.engineerFeeNoRate
        : l10n.engineerFeePercentCaption(BasisPoints.formatPercent(engineerBasisPoints));

    return AppPressable(
      enabled: mutationsEnabled,
      onPressed: onEdit,
      child: Opacity(
        opacity: mutationsEnabled ? 1 : 0.55,
        child: AppCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.engineerEstimatedProfitTitle, style: text.bodyEmphasis),
                    AppSize.spaceXS.gap,
                    Text(
                      '$percentCaption · ${l10n.engineerFeeInternalOnly}',
                      style: text.caption.copyWith(color: colors.onSurfaceMuted),
                    ),
                  ],
                ),
              ),
              AppSize.spaceMD.gap,
              if (estimatedProfitPiastres == null)
                Text(l10n.engineerFeeUndefined, style: text.moneyMd.copyWith(color: colors.primaryDark))
              else
                AppAmount(
                  piastres: estimatedProfitPiastres!,
                  role: AppAmountRole.neutral,
                  size: AppAmountSize.medium,
                  localeCode: localeCode,
                  minorPerMajor: minorPerMajor,
                ),
              AppSize.spaceSM.gap,
              if (mutationsEnabled) const AppChevron.forward(size: AppSize.iconSmall),
            ],
          ),
        ),
      ),
    );
  }
}
