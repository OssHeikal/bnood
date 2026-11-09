import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/money/ledger_math.dart';
import '../../../core/widgets/app_amount.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../l10n/app_localizations.dart';
import '../../items/item_semantic_icon.dart';

class ClientDetailItemRow extends StatelessWidget {
  const ClientDetailItemRow({
    super.key,
    required this.itemName,
    required this.colorKey,
    required this.iconName,
    required this.breakdown,
    required this.localeCode,
    this.minorPerMajor = 100,
    this.onTap,
  });

  final String itemName;
  final String colorKey;
  final String iconName;
  final ItemExpenseBreakdown breakdown;
  final String localeCode;
  final int minorPerMajor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;
    final total = breakdown.totalPiastres;
    final materialsShare = total == 0 ? 0.0 : breakdown.materialsPiastres / total;
    final accent = itemSemanticAccentColor(colorKey);
    final card = AppCard(
      padding: const EdgeInsets.all(AppSize.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Material(
                color: accent.withValues(alpha: 0.15),
                shape: AppShape.superellipse(radius: AppSize.radiusSM),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: AppSize.statIconBox,
                  height: AppSize.statIconBox,
                  child: Center(
                    child: itemSemanticIconWidget(
                      iconKey: iconName,
                      color: accent,
                      size: AppSize.iconSmall,
                    ),
                  ),
                ),
              ),
              AppSize.spaceMD.gap,
              Expanded(child: Text(itemName, style: text.bodyEmphasis, maxLines: 1, overflow: TextOverflow.ellipsis)),
              AppAmount(
                piastres: total,
                role: AppAmountRole.spend,
                size: AppAmountSize.small,
                localeCode: localeCode,
                minorPerMajor: minorPerMajor,
              ),
            ],
          ),
          ...[
            AppSize.spaceMD.gap,
            Row(
              children: [
                _SplitLabel(
                  label: l10n.materials,
                  piastres: breakdown.materialsPiastres,
                  dotColor: colors.receive,
                  localeCode: localeCode,
                  minorPerMajor: minorPerMajor,
                ),
                AppSize.spaceMD.gap,
                _SplitLabel(
                  label: l10n.labor,
                  piastres: breakdown.laborPiastres,
                  dotColor: colors.spend,
                  localeCode: localeCode,
                  minorPerMajor: minorPerMajor,
                ),
              ],
            ),
            AppSize.spaceSM.gap,
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSize.radiusSM),
              child: SizedBox(
                height: 8,
                child: Row(
                  children: [
                    if (materialsShare > 0)
                      Expanded(
                        flex: (materialsShare * 1000).round().clamp(1, 1000),
                        child: ColoredBox(color: colors.receive),
                      ),
                    if (materialsShare < 1)
                      Expanded(
                        flex: ((1 - materialsShare) * 1000).round().clamp(1, 1000),
                        child: ColoredBox(color: colors.spend.withValues(alpha: 0.35)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return card;
    return AppPressable(onPressed: onTap, child: card);
  }
}

class _SplitLabel extends StatelessWidget {
  const _SplitLabel({
    required this.label,
    required this.piastres,
    required this.dotColor,
    required this.localeCode,
    this.minorPerMajor = 100,
  });

  final String label;
  final int piastres;
  final Color dotColor;
  final String localeCode;
  final int minorPerMajor;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          AppSize.spaceXS.gap,
          Flexible(
            child: Text(
              '$label ${AppAmount.format(piastres: piastres, localeCode: localeCode, minorPerMajor: minorPerMajor)}',
              style: text.caption.copyWith(color: context.colors.onSurfaceMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
