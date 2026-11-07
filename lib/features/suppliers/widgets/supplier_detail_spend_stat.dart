import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/resources/gen/assets.gen.dart';
import '../../../core/widgets/app_amount.dart';
import '../../../core/widgets/app_card.dart';
import '../../../app/widgets/shell_nav_icon.dart';
import '../../../l10n/app_localizations.dart';

class SupplierDetailSpendStat extends StatelessWidget {
  const SupplierDetailSpendStat({
    super.key,
    required this.totalPaidPiastres,
    required this.localeCode,
  });

  final int totalPaidPiastres;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;
    final tint = colors.spend;
    final tintBg = colors.errorBg;

    return AppCard(
      padding: const EdgeInsets.all(AppSize.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Material(
                color: tintBg,
                shape: AppShape.superellipse(radius: 10),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: AppSize.statIconBox,
                  height: AppSize.statIconBox,
                  child: Center(
                    child: ShellNavIcon(
                      asset: Assets.icons.arrowUpRightCircleOutline,
                      color: tint,
                      size: AppSize.iconSmall,
                    ),
                  ),
                ),
              ),
              AppSize.spaceSM.gap,
              Expanded(
                child: Text(l10n.supplierTotalPaidLabel, style: text.caption.copyWith(color: colors.onSurfaceMuted)),
              ),
            ],
          ),
          AppSize.spaceMD.gap,
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: AppAmount(
                piastres: totalPaidPiastres,
                role: AppAmountRole.spend,
                size: AppAmountSize.balance,
                localeCode: localeCode,
              ),
            ),
          ),
          AppSize.spaceSM.gap,
          Text(
            l10n.supplierSpendRecordedCaption,
            style: text.caption.copyWith(color: colors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}
