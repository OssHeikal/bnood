import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/theme/app_colors.dart' as legacy;
import '../../../core/widgets/app_amount.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chevron.dart';
import '../../../l10n/app_localizations.dart';
import '../client_detail_snapshot.dart';

class ClientDetailCraftsmanRow extends StatelessWidget {
  const ClientDetailCraftsmanRow({
    super.key,
    required this.preview,
    required this.localeCode,
  });

  final ClientCraftsmanPreviewRow preview;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;
    final accent = legacy.AppColors.accent(preview.accentKey);
    final meta = preview.trade?.trim().isNotEmpty == true
        ? preview.trade!
        : l10n.craftsman;

    return AppCard(
      onTap: () => context.push('/craftsmen/${preview.craftsmanId}'),
      padding: const EdgeInsets.all(AppSize.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _SmallAvatar(initial: preview.name.isNotEmpty ? preview.name[0] : '?', accent: accent),
              AppSize.spaceSM.gap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(preview.name, style: text.bodyEmphasis, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(meta, style: text.caption.copyWith(color: colors.onSurfaceMuted)),
                  ],
                ),
              ),
              const AppChevron.forward(),
            ],
          ),
          AppSize.spaceMD.gap,
          Row(
            children: [
              if (preview.agreedPiastres != null)
                Expanded(
                  child: _Metric(
                    label: l10n.craftsmanAgreedAmount,
                    piastres: preview.agreedPiastres!,
                    role: AppAmountRole.neutral,
                    localeCode: localeCode,
                  ),
                ),
              Expanded(
                child: _Metric(
                  label: l10n.paid,
                  piastres: preview.paidPiastres,
                  role: AppAmountRole.spend,
                  localeCode: localeCode,
                ),
              ),
              if (preview.remainingPiastres != null)
                Expanded(
                  child: _Metric(
                    label: l10n.remaining,
                    piastres: preview.remainingPiastres!,
                    role: AppAmountRole.remaining,
                    localeCode: localeCode,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallAvatar extends StatelessWidget {
  const _SmallAvatar({required this.initial, required this.accent});

  final String initial;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent,
      shape: AppShape.superellipse(radius: 11),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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
  });

  final String label;
  final int piastres;
  final AppAmountRole role;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: context.text.caption.copyWith(color: context.colors.onSurfaceMuted)),
        AppSize.spaceXS.gap,
        AppAmount(piastres: piastres, role: role, size: AppAmountSize.small, localeCode: localeCode),
      ],
    );
  }
}
