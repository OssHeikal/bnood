import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/money/remote_money_units.dart';
import '../../../core/widgets/app_amount.dart';

/// Label above amount, both aligned to the same logical edge (RTL-safe).
class ProviderDetailMetricStack extends StatelessWidget {
  const ProviderDetailMetricStack({
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
    final text = context.text;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            label,
            style: text.caption.copyWith(color: colors.onSurfaceMuted),
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
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
    );
  }
}
