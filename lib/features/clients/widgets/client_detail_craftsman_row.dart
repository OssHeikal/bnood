import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/theme/app_colors.dart' as legacy;
import '../../../core/money/remote_money_units.dart';
import '../../../core/widgets/app_amount.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chevron.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/providers_api/app_provider_record.dart';
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
    final isSupplier = preview.providerType == AppProviderType.supplier;
    final meta = preview.trade?.trim().isNotEmpty == true
        ? preview.trade!
        : (isSupplier ? l10n.suppliers : l10n.craftsman);
    final hasAgreed = preview.agreedPiastres != null;
    final onlineOnly = preview.onlineAgreementsOnly;
    final detailRoute = onlineOnly
        ? '/providers/${preview.craftsmanId}'
        : isSupplier
            ? '/suppliers/${preview.craftsmanId}'
            : '/craftsmen/${preview.craftsmanId}';

    return AppCard(
      onTap: () => context.push(detailRoute),
      padding: const EdgeInsets.all(AppSize.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SmallAvatar(
                initial: preview.name.isNotEmpty ? preview.name[0] : '?',
                accent: accent,
              ),
              const SizedBox(width: AppSize.spaceSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      preview.name,
                      style: text.bodyEmphasis,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      meta,
                      style: text.caption.copyWith(color: colors.onSurfaceMuted),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const AppChevron.forward(),
            ],
          ),
          AppSize.spaceMD.gap,
          if (onlineOnly) ...[
            if (hasAgreed)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Metric(
                        key: const Key('client_craftsman_metric_agreed'),
                        label: l10n.craftsmanAgreedAmount,
                        piastres: preview.agreedPiastres!,
                        role: AppAmountRole.neutral,
                        localeCode: localeCode,
                        minorPerMajor: preview.usesRemoteMoney
                            ? RemoteMoneyUnits.minorPerMajor
                            : 100,
                      ),
                    ),
                    Expanded(
                      child: _Metric(
                        key: const Key('client_craftsman_metric_paid'),
                        label: l10n.paid,
                        piastres: preview.paidPiastres,
                        role: AppAmountRole.spend,
                        localeCode: localeCode,
                        minorPerMajor: preview.usesRemoteMoney
                            ? RemoteMoneyUnits.minorPerMajor
                            : 100,
                      ),
                    ),
                    if (preview.remainingPiastres != null)
                      Expanded(
                        child: _Metric(
                          key: const Key('client_craftsman_metric_remaining'),
                          label: l10n.remaining,
                          piastres: preview.remainingPiastres!,
                          role: AppAmountRole.remaining,
                          localeCode: localeCode,
                          minorPerMajor: preview.usesRemoteMoney
                              ? RemoteMoneyUnits.minorPerMajor
                              : 100,
                        ),
                      ),
                  ],
                ),
              )
            else
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: IntrinsicWidth(
                  child: _Metric(
                    key: const Key('client_craftsman_metric_paid'),
                    label: l10n.paid,
                    piastres: preview.paidPiastres,
                    role: AppAmountRole.spend,
                    localeCode: localeCode,
                    minorPerMajor: preview.usesRemoteMoney
                        ? RemoteMoneyUnits.minorPerMajor
                        : 100,
                  ),
                ),
              ),
          ] else if (hasAgreed)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Metric(
                      key: const Key('client_craftsman_metric_agreed'),
                      label: l10n.craftsmanAgreedAmount,
                      piastres: preview.agreedPiastres!,
                      role: AppAmountRole.neutral,
                      localeCode: localeCode,
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      key: const Key('client_craftsman_metric_paid'),
                      label: l10n.paid,
                      piastres: preview.paidPiastres,
                      role: AppAmountRole.spend,
                      localeCode: localeCode,
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      key: const Key('client_craftsman_metric_remaining'),
                      label: l10n.remaining,
                      piastres: preview.remainingPiastres!,
                      role: AppAmountRole.remaining,
                      localeCode: localeCode,
                    ),
                  ),
                ],
              ),
            )
          else
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IntrinsicWidth(
                child: _Metric(
                  key: const Key('client_craftsman_metric_paid'),
                  label: l10n.paid,
                  piastres: preview.paidPiastres,
                  role: AppAmountRole.spend,
                  localeCode: localeCode,
                ),
              ),
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
          child: Text(
            initial,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    super.key,
    required this.label,
    required this.piastres,
    required this.role,
    required this.localeCode,
    this.minorPerMajor = 100,
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
