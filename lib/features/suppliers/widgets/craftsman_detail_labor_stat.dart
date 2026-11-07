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

class CraftsmanDetailLaborStat extends StatelessWidget {
  const CraftsmanDetailLaborStat({
    super.key,
    required this.totalLaborPaidPiastres,
    required this.linkedProjectCount,
    required this.localeCode,
  });

  final int totalLaborPaidPiastres;
  final int linkedProjectCount;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;

    return AppCard(
      padding: const EdgeInsets.all(AppSize.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Material(
                color: colors.errorBg,
                shape: AppShape.superellipse(radius: 10),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: AppSize.statIconBox,
                  height: AppSize.statIconBox,
                  child: Center(
                    child: ShellNavIcon(
                      asset: Assets.icons.arrowUpRightCircleOutline,
                      color: colors.spend,
                      size: AppSize.iconSmall,
                    ),
                  ),
                ),
              ),
              AppSize.spaceSM.gap,
              Expanded(
                child: Text(
                  l10n.craftsmanTotalLaborPaidLabel,
                  style: text.caption.copyWith(color: colors.onSurfaceMuted),
                ),
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
                piastres: totalLaborPaidPiastres,
                role: AppAmountRole.spend,
                size: AppAmountSize.balance,
                localeCode: localeCode,
              ),
            ),
          ),
          AppSize.spaceSM.gap,
          Text(
            l10n.craftsmanLaborStatCaption(linkedProjectCount),
            style: text.caption.copyWith(color: colors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}
