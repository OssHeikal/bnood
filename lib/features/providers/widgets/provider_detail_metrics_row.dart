import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/money/remote_money_units.dart';
import '../../../core/widgets/app_amount.dart';

class ProviderDetailMetricsRow extends StatelessWidget {
  const ProviderDetailMetricsRow({
    super.key,
    required this.agreedLabel,
    required this.paidLabel,
    required this.remainingLabel,
    required this.localeCode,
    this.agreedMinor,
    required this.paidMinor,
    this.remainingMinor,
    this.minorPerMajor = RemoteMoneyUnits.minorPerMajor,
  });

  final String agreedLabel;
  final String paidLabel;
  final String remainingLabel;
  final String localeCode;
  final int? agreedMinor;
  final int paidMinor;
  final int? remainingMinor;
  final int minorPerMajor;

  @override
  Widget build(BuildContext context) {
    final showAgreed = agreedMinor != null;
    final showRemaining = remainingMinor != null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAgreed)
            Expanded(
              child: _ProviderDetailMetric(
                label: agreedLabel,
                piastres: agreedMinor!,
                role: AppAmountRole.neutral,
                localeCode: localeCode,
                minorPerMajor: minorPerMajor,
              ),
            ),
          Expanded(
            child: _ProviderDetailMetric(
              label: paidLabel,
              piastres: paidMinor,
              role: AppAmountRole.spend,
              localeCode: localeCode,
              minorPerMajor: minorPerMajor,
            ),
          ),
          if (showRemaining)
            Expanded(
              child: _ProviderDetailMetric(
                label: remainingLabel,
                piastres: remainingMinor!,
                role: AppAmountRole.remaining,
                localeCode: localeCode,
                minorPerMajor: minorPerMajor,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProviderDetailMetric extends StatelessWidget {
  const _ProviderDetailMetric({
    required this.label,
    required this.piastres,
    required this.role,
    required this.localeCode,
    required this.minorPerMajor,
  });

  final String label;
  final int piastres;
  final AppAmountRole role;
  final String localeCode;
  final int minorPerMajor;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSize.spaceXS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: text.caption.copyWith(color: colors.onSurfaceMuted),
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          AppSize.spaceXS.gap,
          AppAmount(
            piastres: piastres,
            role: role,
            size: AppAmountSize.small,
            localeCode: localeCode,
            minorPerMajor: minorPerMajor,
          ),
        ],
      ),
    );
  }
}
