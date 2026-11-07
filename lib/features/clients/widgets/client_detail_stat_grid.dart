import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/repositories/bnood_repository.dart';
import '../../../core/resources/gen/assets.gen.dart';
import '../../../core/widgets/app_amount.dart';
import '../../../core/widgets/app_card.dart';
import '../../../app/widgets/shell_nav_icon.dart';
import '../../../l10n/app_localizations.dart';

/// Client detail totals — remaining label is [AppLocalizations.remaining], not home custody copy.
class ClientDetailStatGrid extends StatelessWidget {
  const ClientDetailStatGrid({
    super.key,
    required this.totals,
    required this.localeCode,
  });

  final HomeTotals totals;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labelStyle = context.text.label.copyWith(fontSize: 14);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StatTile(
                preset: AppCardPreset.statReceive,
                label: l10n.received,
                labelStyle: labelStyle,
                amount: totals.receivedPiastres,
                role: AppAmountRole.receive,
                icon: Assets.icons.arrowDownLeftCircleOutline,
                tint: context.colors.success,
                tintBg: context.colors.successBg,
                localeCode: localeCode,
              ),
            ),
            AppSize.spaceMD.gap,
            Expanded(
              child: _StatTile(
                preset: AppCardPreset.statSpend,
                label: l10n.spent,
                labelStyle: labelStyle,
                amount: totals.spentPiastres,
                role: AppAmountRole.spend,
                icon: Assets.icons.arrowUpRightCircleOutline,
                tint: context.colors.spend,
                tintBg: context.colors.errorBg,
                localeCode: localeCode,
              ),
            ),
          ],
        ),
        AppSize.spaceMD.gap,
        _StatTile(
          preset: AppCardPreset.statRemaining,
          label: l10n.remaining,
          labelStyle: labelStyle,
          amount: totals.remainingPiastres,
          role: AppAmountRole.remaining,
          amountEmphasis: AppAmountSize.balance,
          icon: Assets.icons.balanceWalletOutline,
          tint: context.colors.remaining,
          tintBg: context.colors.infoBg,
          localeCode: localeCode,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.preset,
    required this.label,
    required this.labelStyle,
    required this.amount,
    required this.role,
    required this.icon,
    required this.tint,
    required this.tintBg,
    required this.localeCode,
    this.amountEmphasis = AppAmountSize.medium,
  });

  final AppCardPreset preset;
  final String label;
  final TextStyle labelStyle;
  final int amount;
  final AppAmountRole role;
  final AppAmountSize amountEmphasis;
  final SvgGenImage icon;
  final Color tint;
  final Color tintBg;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      preset: preset,
      padding: const EdgeInsets.all(AppSize.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _IconBubble(icon: icon, tint: tint, tintBg: tintBg),
              AppSize.spaceSM.gap,
              Expanded(child: Text(label, style: labelStyle)),
            ],
          ),
          AppSize.spaceMD.gap,
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: AppAmount(piastres: amount, role: role, size: amountEmphasis, localeCode: localeCode),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon, required this.tint, required this.tintBg});

  final SvgGenImage icon;
  final Color tint;
  final Color tintBg;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tintBg,
      shape: AppShape.superellipse(radius: 10),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: AppSize.statIconBox,
        height: AppSize.statIconBox,
        child: Center(child: ShellNavIcon(asset: icon, color: tint, size: AppSize.iconSmall)),
      ),
    );
  }
}
