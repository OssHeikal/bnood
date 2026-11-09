import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_amount.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../l10n/app_localizations.dart';
import '../../clients/agreement_mutation_actions.dart';
import '../../clients/craftsman_agreement_amount_sheet.dart';
import '../provider_detail_snapshot.dart';

class ProviderDetailClientAgreementCard extends ConsumerWidget {
  const ProviderDetailClientAgreementCard({
    super.key,
    required this.row,
    required this.providerId,
    required this.providerName,
    required this.localeCode,
    required this.onChanged,
  });

  final ProviderDetailClientRow row;
  final String providerId;
  final String providerName;
  final String localeCode;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;
    final agreement = row.agreement;
    final hasAgreed = agreement.hasAgreedAmount;

    return AppCard(
      padding: const EdgeInsets.all(AppSize.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AppPressable(
                  onPressed: () => context.push('/clients/${agreement.clientId}'),
                  child: Text(
                    row.clientName,
                    style: text.bodyEmphasis.copyWith(color: colors.primaryDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              AppPressable(
                key: Key('provider_detail_edit_agreement_${agreement.id}'),
                onPressed: () async {
                  await showRemoteAgreementAmountEditSheet(
                    context: context,
                    ref: ref,
                    agreementId: agreement.id,
                    clientId: agreement.clientId,
                    providerId: providerId,
                    clientName: row.clientName,
                    craftsmanName: providerName,
                    initialAmountPiastres: agreement.amountPiastres,
                  );
                  if (context.mounted) await onChanged();
                },
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSize.spaceSM,
                    AppSize.spaceXS,
                    AppSize.spaceSM,
                    AppSize.spaceXS,
                  ),
                  child: Text(
                    l10n.craftsmanDetailEditAgreement,
                    style: text.caption.copyWith(
                      color: colors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ],
          ),
          if (!hasAgreed) ...[
            AppSize.spaceSM.gap,
            Text(
              l10n.craftsmanDetailNoAgreedAmount,
              style: text.caption.copyWith(color: colors.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
          ] else ...[
            AppSize.spaceMD.gap,
            Row(
              children: [
                Text(
                  l10n.craftsmanAgreedAmount,
                  style: text.caption.copyWith(color: colors.onSurfaceMuted),
                ),
                AppSize.spaceSM.gap,
                AppAmount(
                  piastres: agreement.amountPiastres!,
                  role: AppAmountRole.neutral,
                  size: AppAmountSize.small,
                  localeCode: localeCode,
                ),
              ],
            ),
          ],
          AppSize.spaceSM.gap,
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              key: Key('provider_detail_unlink_${agreement.id}'),
              onPressed: () async {
                final ok = await confirmUnlinkAgreement(
                  context: context,
                  ref: ref,
                  agreementId: agreement.id,
                  craftsmanName: providerName,
                  clientId: agreement.clientId,
                  providerId: providerId,
                );
                if (ok && context.mounted) await onChanged();
              },
              child: Text(
                l10n.unlink,
                style: text.caption.copyWith(color: colors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
