import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/money/remote_money_units.dart';
import '../../../core/utils/extensions/bidi_isolate.dart';
import '../../../core/providers_api/app_provider_record.dart';
import '../../../core/theme/app_colors.dart' as legacy;
import '../../../core/resources/gen/assets.gen.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_overflow_menu.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../features/suppliers/widgets/directory_person_card.dart';
import '../../../l10n/app_localizations.dart';
import 'remote_craftsman_summary_card.dart';

class ProvidersListTile extends ConsumerWidget {
  const ProvidersListTile({
    super.key,
    required this.provider,
    required this.onOpenDetail,
    required this.onEdit,
    required this.onDelete,
  });

  final AppProvider provider;
  final VoidCallback onOpenDetail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const _stripeWidth = 4.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context);

    if (provider.type == AppProviderType.craftsman && provider.paidMinor != null) {
      return RemoteCraftsmanSummaryCard(
        name: provider.name,
        accentKey: directoryAccentKeyFor(provider.id),
        localeCode: localeCode,
        clientsCount: provider.clientsCount ?? 0,
        paidPiastres: provider.paidMinor!,
        remainingPiastres: provider.remainingMinor,
        minorPerMajor: RemoteMoneyUnits.minorPerMajor,
        onTap: onOpenDetail,
        overflowActions: craftsmanProviderOverflowActions(
          l10n: l10n,
          onOpenDetail: onOpenDetail,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      );
    }

    final colors = context.colors;
    final text = context.text;
    final accent = legacy.AppColors.accent(directoryAccentKeyFor(provider.id));
    final kindMeta = provider.type == AppProviderType.supplier
        ? l10n.directorySupplierKindMeta
        : l10n.directoryCraftsmanKindMeta;
    final phone = provider.phone;

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
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSize.spaceLG,
                    AppSize.spaceMD,
                    AppSize.spaceSM,
                    AppSize.spaceMD,
                  ),
                  child: Row(
                    children: [
                      _Avatar(initial: provider.name.isNotEmpty ? provider.name[0] : '?', accent: accent),
                      AppSize.spaceMD.gap,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.name,
                              style: text.bodyEmphasis.copyWith(color: colors.onSurface),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppSize.spaceXS.gap,
                            Text(
                              kindMeta,
                              style: text.caption.copyWith(color: colors.onSurfaceMuted),
                            ),
                            if (phone != null && phone.isNotEmpty) ...[
                              AppSize.spaceXS.gap,
                              Text(
                                LtrIsolate.isolate(phone),
                                style: text.caption.copyWith(color: colors.onSurfaceMuted),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: AppSize.spaceSM),
              child: Center(
                child: AppOverflowMenu(
                  actions: [
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
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: accent.withValues(alpha: 0.15),
        shape: AppShape.circle,
      ),
      child: Text(
        initial,
        style: context.text.bodyEmphasis.copyWith(color: accent),
      ),
    );
  }
}
