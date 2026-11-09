import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/theme/app_colors.dart' as legacy;
import '../../../core/resources/gen/assets.gen.dart';
import '../../../core/widgets/app_amount.dart';
import '../../../core/widgets/app_card.dart';
import '../../../app/widgets/shell_nav_icon.dart';
import '../../../l10n/app_localizations.dart';

/// Client row: stripe inside card, remaining under name, in/out in trailing column.
/// Amount-only trailing (`showAmountCaption: false`): name and amount, no subtitle.
class ClientBalanceCard extends StatelessWidget {
  const ClientBalanceCard({
    super.key,
    required this.name,
    this.meta,
    required this.amountPiastres,
    required this.accentKey,
    required this.localeCode,
    required this.onTap,
    this.amountRole = AppAmountRole.remaining,
    this.amountCaption,
    this.showAmountCaption = true,
    this.receivedPiastres,
    this.spentPiastres,
  });

  final String name;
  final String? meta;
  final int? receivedPiastres;
  final int? spentPiastres;
  final int? amountPiastres;
  final String accentKey;
  final String localeCode;
  final VoidCallback onTap;
  final AppAmountRole amountRole;
  final String? amountCaption;
  final bool showAmountCaption;

  static const _stripeWidth = 4.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final accent = legacy.AppColors.accent(accentKey);
    final caption = showAmountCaption
        ? (amountCaption ?? AppLocalizations.of(context).remaining)
        : null;
    final showClientFlows = receivedPiastres != null && spentPiastres != null;
    final hasAmount = amountPiastres != null;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      radius: AppSize.radiusMD,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: accent,
              child: const SizedBox(width: _stripeWidth),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG, vertical: AppSize.spaceMD),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Avatar(initial: name.isNotEmpty ? name[0] : '?', accent: accent),
                    AppSize.spaceMD.gap,
                    Expanded(
                      flex: 11,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(name, style: text.bodyEmphasis, maxLines: 1, overflow: TextOverflow.ellipsis),
                          if (showClientFlows) ...[
                            AppSize.spaceXS.gap,
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: hasAmount
                                  ? AppAmount(
                                      piastres: amountPiastres!,
                                      role: amountRole,
                                      size: AppAmountSize.small,
                                      localeCode: localeCode,
                                    )
                                  : Text(
                                      AppLocalizations.of(context).amountUnavailable,
                                      style: text.moneySm.copyWith(color: colors.onSurfaceMuted),
                                      textDirection: TextDirection.ltr,
                                    ),
                            ),
                          ] else if (meta != null && meta!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              meta!,
                              style: text.caption.copyWith(color: colors.onSurfaceMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (showClientFlows) AppSize.spaceSM.gap else AppSize.spaceMD.gap,
                    Expanded(
                      flex: 9,
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: showClientFlows
                            ? ClientInOutTrailing(
                                receivedPiastres: receivedPiastres!,
                                spentPiastres: spentPiastres!,
                                localeCode: localeCode,
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (caption != null)
                                    Text(caption, style: text.caption.copyWith(color: colors.onSurfaceMuted)),
                                  if (hasAmount)
                                    AppAmount(
                                      piastres: amountPiastres!,
                                      role: amountRole,
                                      size: AppAmountSize.small,
                                      localeCode: localeCode,
                                    )
                                  else
                                    Text(
                                      AppLocalizations.of(context).amountUnavailable,
                                      style: text.moneySm.copyWith(color: colors.onSurfaceMuted),
                                      textDirection: TextDirection.ltr,
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientInOutTrailing extends StatelessWidget {
  const ClientInOutTrailing({
    super.key,
    required this.receivedPiastres,
    required this.spentPiastres,
    required this.localeCode,
  });

  final int receivedPiastres;
  final int spentPiastres;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerEnd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _FlowAmount(
              icon: Assets.icons.arrowDownLeftCircleOutline,
              tint: colors.receive,
              piastres: receivedPiastres,
              role: AppAmountRole.receive,
              localeCode: localeCode,
            ),
            AppSize.spaceXS.gap,
            _FlowAmount(
              icon: Assets.icons.arrowUpRightCircleOutline,
              tint: colors.spend,
              piastres: spentPiastres,
              role: AppAmountRole.spend,
              localeCode: localeCode,
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowAmount extends StatelessWidget {
  const _FlowAmount({
    required this.icon,
    required this.tint,
    required this.piastres,
    required this.role,
    required this.localeCode,
  });

  final SvgGenImage icon;
  final Color tint;
  final int piastres;
  final AppAmountRole role;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShellNavIcon(asset: icon, color: tint, size: AppSize.iconSmall),
        const SizedBox(width: AppSize.spaceXS),
        AppAmount(piastres: piastres, role: role, size: AppAmountSize.small, localeCode: localeCode),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial, required this.accent});

  final String initial;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: AppShape.superellipse(radius: 14),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent, Color.lerp(accent, Colors.black, 0.25)!],
          ),
        ),
        child: SizedBox(
          width: AppSize.hitMin,
          height: AppSize.hitMin,
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

String clientAccentKeyFor(String id) {
  const keys = ['teal', 'green', 'blue', 'purple', 'pink', 'orange', 'gold', 'brick', 'turquoise', 'olive'];
  return keys[id.hashCode.abs() % keys.length];
}
