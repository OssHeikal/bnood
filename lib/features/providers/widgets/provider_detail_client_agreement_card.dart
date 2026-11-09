import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/money/remote_money_units.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../l10n/app_localizations.dart';
import '../provider_detail_snapshot.dart';
import 'provider_detail_metrics_row.dart';

class ProviderDetailClientAgreementCard extends StatelessWidget {
  const ProviderDetailClientAgreementCard({
    super.key,
    required this.row,
    required this.localeCode,
    this.radius = AppSize.radiusMD,
    this.clipBottom = false,
  });

  final ProviderDetailClientRow row;
  final String localeCode;
  final double radius;
  final bool clipBottom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;
    final agreement = row.agreement;
    final hasAgreed = agreement.hasAgreedAmount;
    final amountMinor = agreement.amountMinorForDisplay;
    final minorPerMajor = agreement.amountMajor != null
        ? RemoteMoneyUnits.minorPerMajor
        : 100;

    final borderRadius = clipBottom
        ? BorderRadius.vertical(top: Radius.circular(radius))
        : BorderRadius.circular(radius);

    return Material(
      color: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: colors.outlineSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppSize.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPressable(
              onPressed: () => context.push('/clients/${agreement.clientId}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    row.clientName,
                    style: text.bodyEmphasis.copyWith(color: colors.primaryDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            if (!hasAgreed) ...[
              AppSize.spaceSM.gap,
              Text(
                l10n.craftsmanDetailNoAgreedAmount,
                style: text.caption.copyWith(color: colors.onSurfaceMuted),
                textAlign: TextAlign.start,
              ),
            ],
            if (hasAgreed && amountMinor != null) ...[
              AppSize.spaceMD.gap,
              ProviderDetailMetricsRow(
                agreedLabel: l10n.craftsmanAgreedAmount,
                paidLabel: l10n.paid,
                remainingLabel: l10n.remaining,
                localeCode: localeCode,
                agreedMinor: amountMinor,
                paidMinor: agreement.paidMinorForDisplay,
                remainingMinor: agreement.remainingMinorForDisplay,
                minorPerMajor: minorPerMajor,
              ),
            ] else if (!hasAgreed) ...[
              AppSize.spaceMD.gap,
              ProviderDetailMetricsRow(
                agreedLabel: l10n.craftsmanAgreedAmount,
                paidLabel: l10n.paid,
                remainingLabel: l10n.remaining,
                localeCode: localeCode,
                paidMinor: agreement.paidMinorForDisplay,
                minorPerMajor: minorPerMajor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
