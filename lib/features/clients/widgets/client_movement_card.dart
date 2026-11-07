import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/formatting/display_digits.dart';
import '../../../core/resources/gen/assets.gen.dart';
import '../../../core/widgets/app_amount.dart';
import '../../../app/widgets/shell_nav_icon.dart';
import '../../../l10n/app_localizations.dart';
import '../client_detail_snapshot.dart';

/// Approved transaction card body (detail grouped card and full movements list).
class ClientMovementCard extends StatelessWidget {
  const ClientMovementCard({
    super.key,
    required this.line,
    required this.localeCode,
    this.padding = const EdgeInsets.symmetric(vertical: AppSize.spaceSM),
  });

  final ClientDetailMovementLine line;
  final String localeCode;
  final EdgeInsetsGeometry padding;

  static String formatMovementDate(DateTime date, String localeCode) {
    final locale = localeCode == 'ar' ? 'ar_EG' : 'en_US';
    final formatted = DateFormat('EEE dd MMM yyyy', locale).format(date.toLocal());
    return DisplayDigits.toWesternDigits(formatted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;
    final t = line.transaction;
    final isReceive = t.kind == 'receive';
    final tint = isReceive ? colors.receive : colors.spend;
    final tintBg = isReceive ? colors.successBg : colors.errorBg;
    final icon = isReceive ? Assets.icons.arrowDownLeftCircleOutline : Assets.icons.arrowUpRightCircleOutline;

    final title = isReceive ? l10n.clientReceiveMovementDetail : (line.itemName ?? l10n.clientDetailUnspecifiedItem);
    final subtitle = line.payeeName?.trim();
    final description = t.description?.trim();
    final showDescription = description != null && description.isNotEmpty;

    final dateLabel = formatMovementDate(t.date, localeCode);
    final methodLabel = t.method == 'transfer' ? l10n.transfer : l10n.cash;

    final badges = <_BadgeSpec>[
      if (!isReceive && t.expenseType != null)
        _BadgeSpec(
          label: t.expenseType == 'labor' ? l10n.labor : l10n.materials,
          color: colors.onSurfaceMuted,
          bg: colors.surfaceSunken,
        ),
      _BadgeSpec(
        label: methodLabel,
        color: colors.onSurfaceMuted,
        bg: colors.surfaceSunken,
      ),
    ];

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: Directionality.of(context),
            children: [
              Material(
                color: tintBg,
                shape: AppShape.superellipse(radius: 10),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: AppSize.statIconBox,
                  height: AppSize.statIconBox,
                  child: Center(
                    child: ShellNavIcon(asset: icon, color: tint, size: AppSize.iconSmall),
                  ),
                ),
              ),
              AppSize.spaceMD.gap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.body.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      AppSize.spaceXS.gap,
                      Text(
                        subtitle,
                        style: text.caption.copyWith(color: colors.onSurfaceMuted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              AppSize.spaceSM.gap,
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: AppAmount(
                        piastres: t.amountPiastres,
                        role: isReceive ? AppAmountRole.receive : AppAmountRole.spend,
                        size: AppAmountSize.medium,
                        localeCode: localeCode,
                      ),
                    ),
                    AppSize.spaceXS.gap,
                    Text(
                      dateLabel,
                      style: text.caption.copyWith(color: colors.onSurfaceMuted),
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showDescription) ...[
            AppSize.spaceSM.gap,
            Text(
              description,
              style: text.caption.copyWith(color: colors.onSurfaceMuted),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (badges.isNotEmpty) ...[
            AppSize.spaceSM.gap,
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Wrap(
                spacing: AppSize.spaceXS,
                runSpacing: AppSize.spaceXS,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final badge in badges)
                    _MovementBadge(label: badge.label, color: badge.color, bg: badge.bg),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BadgeSpec {
  const _BadgeSpec({required this.label, required this.color, required this.bg});

  final String label;
  final Color color;
  final Color bg;
}

class _MovementBadge extends StatelessWidget {
  const _MovementBadge({required this.label, required this.color, required this.bg});

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppSize.radiusSM)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceSM, vertical: 2),
        child: Text(label, style: context.text.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
