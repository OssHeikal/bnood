import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../l10n/app_localizations.dart';
import '../../clients/agreement_mutation_actions.dart';
import '../../clients/craftsman_agreement_amount_sheet.dart';
import '../provider_detail_snapshot.dart';

class ProviderDetailClientAgreementActions extends ConsumerWidget {
  const ProviderDetailClientAgreementActions({
    super.key,
    required this.row,
    required this.providerId,
    required this.providerName,
    required this.onChanged,
  });

  final ProviderDetailClientRow row;
  final String providerId;
  final String providerName;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;
    final agreement = row.agreement;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppSize.radiusMD)),
        border: Border.all(color: colors.outlineSubtle),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.spaceSM,
        vertical: AppSize.spaceXS,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppPressable(
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
                  initialAmountPiastres: agreement.amountMinorForDisplay,
                );
                if (context.mounted) await onChanged();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.spaceSM,
                  vertical: AppSize.spaceSM,
                ),
                child: Text(
                  l10n.craftsmanDetailEditAgreement,
                  style: text.body.copyWith(
                    color: colors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: AppSize.spaceXL,
            color: colors.outlineSubtle,
          ),
          Expanded(
            child: AppPressable(
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
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.spaceSM,
                  vertical: AppSize.spaceSM,
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.unlink,
                  style: text.body.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
