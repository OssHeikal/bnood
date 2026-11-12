import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/theme/app_colors.dart' as legacy;
import '../../../core/widgets/app_amount.dart';
import '../../../core/resources/gen/assets.gen.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_overflow_menu.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../features/clients/widgets/client_balance_card.dart';
import '../../../l10n/app_localizations.dart';

/// Directory list row: stripe, avatar, name, paid subtitle, overflow menu.
/// Craftsman rows set [paidInTrailing]: paid amount at the end, remaining amount under the name.
class DirectoryPersonCard extends StatelessWidget {
  const DirectoryPersonCard({
    super.key,
    required this.name,
    required this.paidPiastres,
    required this.accentKey,
    required this.localeCode,
    required this.onOpenDetail,
    this.onArchive,
    this.trade,
    this.remainingPiastres,
    this.paidInTrailing = false,
    this.showOverflowMenu = true,
  });

  final String name;
  final int paidPiastres;
  final int? remainingPiastres;
  final bool paidInTrailing;
  final String accentKey;
  final String localeCode;
  final VoidCallback onOpenDetail;
  final Future<void> Function()? onArchive;
  final String? trade;
  final bool showOverflowMenu;

  static const _stripeWidth = 4.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = AppLocalizations.of(context);
    final accent = legacy.AppColors.accent(accentKey);

    return AppCard(
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
              child: AppPressable(
                onPressed: onOpenDetail,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: AppSize.spaceLG,
                    top: AppSize.spaceMD,
                    bottom: AppSize.spaceMD,
                    end: paidInTrailing && !showOverflowMenu ? AppSize.spaceLG : AppSize.spaceSM,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _Avatar(initial: name.isNotEmpty ? name[0] : '?', accent: accent),
                      AppSize.spaceMD.gap,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              style: text.bodyEmphasis,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (trade != null && trade!.trim().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                trade!,
                                style: text.caption.copyWith(color: colors.onSurfaceMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (paidInTrailing && remainingPiastres != null) ...[
                              const SizedBox(height: 2),
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: AppAmount(
                                  piastres: remainingPiastres!,
                                  role: AppAmountRole.remaining,
                                  size: AppAmountSize.small,
                                  localeCode: localeCode,
                                ),
                              ),
                            ],
                            if (!paidInTrailing) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${l10n.paid}: ',
                                      style: text.caption.copyWith(color: colors.onSurfaceMuted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  AppAmount(
                                    piastres: paidPiastres,
                                    role: AppAmountRole.spend,
                                    size: AppAmountSize.small,
                                    localeCode: localeCode,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (paidInTrailing) ...[
                        AppSize.spaceSM.gap,
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: AppAmount(
                            piastres: paidPiastres,
                            role: AppAmountRole.spend,
                            size: AppAmountSize.small,
                            localeCode: localeCode,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (showOverflowMenu && onArchive != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: AppSize.spaceSM),
                child: Center(
                  child: AppOverflowMenu(
                    buttonKey: Key('directory_person_menu_$name'),
                    actions: [
                      AppOverflowMenuAction(
                        label: l10n.directoryViewDetails,
                        icon: Assets.icons.infoCircleOutline,
                        onSelected: onOpenDetail,
                      ),
                      AppOverflowMenuAction(
                        label: l10n.archive,
                        icon: Assets.icons.archiveRestoreOutline,
                        onSelected: () {
                          onArchive!();
                        },
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

String directoryAccentKeyFor(String id) => clientAccentKeyFor(id);
