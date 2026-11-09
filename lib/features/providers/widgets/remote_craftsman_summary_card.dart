import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/money/remote_money_units.dart';
import '../../../core/resources/gen/assets.gen.dart';
import '../../../core/theme/app_colors.dart' as legacy;
import '../../../core/widgets/app_amount.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_overflow_menu.dart';
import '../../../l10n/app_localizations.dart';

/// Remote craftsman row: linked clients subtitle, paid + optional remaining metrics.
class RemoteCraftsmanSummaryCard extends StatelessWidget {
  const RemoteCraftsmanSummaryCard({
    super.key,
    required this.name,
    required this.accentKey,
    required this.localeCode,
    required this.clientsCount,
    required this.paidPiastres,
    required this.onTap,
    this.remainingPiastres,
    this.minorPerMajor = RemoteMoneyUnits.minorPerMajor,
    this.overflowActions,
  });

  final String name;
  final String accentKey;
  final String localeCode;
  final int clientsCount;
  final int paidPiastres;
  final int? remainingPiastres;
  final int minorPerMajor;
  final VoidCallback onTap;
  final List<AppOverflowMenuAction>? overflowActions;

  static const _stripeWidth = 4.0;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final accent = legacy.AppColors.accent(accentKey);
    final initial = name.isNotEmpty ? name.characters.first : '?';
    final actions = overflowActions;

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
                padding: EdgeInsetsDirectional.fromSTEB(
                  AppSize.spaceLG,
                  AppSize.spaceMD,
                  actions == null ? AppSize.spaceLG : AppSize.spaceSM,
                  AppSize.spaceMD,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _Avatar(initial: initial, accent: accent),
                        AppSize.spaceMD.gap,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                name,
                                style: text.bodyEmphasis,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                              ),
                              AppSize.spaceXS.gap,
                              Text(
                                l10n.craftsmanLinkedClientsMeta(clientsCount),
                                style: text.caption.copyWith(color: colors.onSurfaceMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppSize.spaceMD.gap,
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _Metric(
                              label: l10n.paid,
                              piastres: paidPiastres,
                              role: AppAmountRole.spend,
                              localeCode: localeCode,
                              minorPerMajor: minorPerMajor,
                            ),
                          ),
                          if (remainingPiastres != null)
                            Expanded(
                              child: _Metric(
                                label: l10n.remaining,
                                piastres: remainingPiastres!,
                                role: AppAmountRole.remaining,
                                localeCode: localeCode,
                                minorPerMajor: minorPerMajor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (actions != null && actions.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: AppSize.spaceSM),
                child: Center(
                  child: AppOverflowMenu(actions: actions),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
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

List<AppOverflowMenuAction> craftsmanProviderOverflowActions({
  required AppLocalizations l10n,
  required VoidCallback onOpenDetail,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) =>
    [
      AppOverflowMenuAction(
        label: l10n.edit,
        icon: Assets.icons.documentEditOutline,
        onSelected: onEdit,
      ),
      AppOverflowMenuAction(
        label: l10n.delete,
        icon: Assets.icons.deleteSquareOutline,
        onSelected: onDelete,
        destructive: true,
      ),
    ];
