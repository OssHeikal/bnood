import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/money/remote_money_units.dart';
import '../../../core/resources/gen/assets.gen.dart';
import '../../../core/theme/app_colors.dart' as legacy;
import '../../../core/utils/extensions/bidi_isolate.dart';
import '../../../core/widgets/app_amount.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_overflow_menu.dart';
import '../../../l10n/app_localizations.dart';

/// Provider row shared by suppliers and craftsmen.
/// Header is a title plus one subtitle. Kind, when set, is a badge on the title row.
class RemoteCraftsmanSummaryCard extends StatelessWidget {
  const RemoteCraftsmanSummaryCard({
    super.key,
    required this.name,
    required this.accentKey,
    required this.localeCode,
    required this.onTap,
    this.kindLabel,
    this.clientsCount,
    this.phone,
    this.paidPiastres,
    this.remainingPiastres,
    this.minorPerMajor = RemoteMoneyUnits.minorPerMajor,
    this.overflowActions,
  });

  final String name;
  final String accentKey;
  final String localeCode;
  final String? kindLabel;
  final int? clientsCount;
  final String? phone;
  final int? paidPiastres;
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
    final kind = kindLabel?.trim();
    final subtitle = _subtitle(l10n);
    final showPaid = paidPiastres != null;
    final showRemaining = remainingPiastres != null;

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
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      name,
                                      style: text.bodyEmphasis,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  if (kind != null && kind.isNotEmpty) ...[
                                    AppSize.spaceXS.gap,
                                    _KindBadge(label: kind, color: accent),
                                  ],
                                ],
                              ),
                              if (subtitle != null) ...[
                                AppSize.spaceXS.gap,
                                Text(
                                  subtitle.isolate ? LtrIsolate.isolate(subtitle.text) : subtitle.text,
                                  style: text.caption.copyWith(color: colors.onSurfaceMuted),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (showPaid || showRemaining) ...[
                      AppSize.spaceSM.gap,
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showPaid)
                              Expanded(
                                child: _Metric(
                                  label: l10n.paid,
                                  piastres: paidPiastres!,
                                  role: AppAmountRole.spend,
                                  localeCode: localeCode,
                                  minorPerMajor: minorPerMajor,
                                ),
                              ),
                            if (showRemaining)
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
                  ],
                ),
              ),
            ),
            if (actions != null && actions.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: AppSize.spaceXS, end: AppSize.spaceXS),
                child: Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: AppOverflowMenu(actions: actions),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _Subtitle? _subtitle(AppLocalizations l10n) {
    final count = clientsCount;
    if (count != null) {
      return _Subtitle(l10n.craftsmanLinkedClientsMeta(count));
    }
    final number = phone?.trim();
    if (number != null && number.isNotEmpty) {
      return _Subtitle(number, isolate: true);
    }
    return null;
  }
}

class _Subtitle {
  const _Subtitle(this.text, {this.isolate = false});

  final String text;
  final bool isolate;
}

class _KindBadge extends StatelessWidget {
  const _KindBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.12),
        shape: AppShape.superellipse(radius: AppSize.radiusSM),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceSM, vertical: 2),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.caption.copyWith(color: color, fontWeight: FontWeight.w700),
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

List<AppOverflowMenuAction> providerOverflowActions({
  required AppLocalizations l10n,
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
