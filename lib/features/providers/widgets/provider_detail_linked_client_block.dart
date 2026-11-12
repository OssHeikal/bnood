import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../clients/agreement_mutation_actions.dart';
import '../../clients/craftsman_agreement_amount_sheet.dart';
import '../../clients/widgets/linked_agreement_overflow_menu.dart';
import '../provider_detail_snapshot.dart';
import 'provider_detail_client_agreement_card.dart';

class ProviderDetailLinkedClientBlock extends ConsumerWidget {
  const ProviderDetailLinkedClientBlock({
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
    final agreement = row.agreement;

    return ProviderDetailClientAgreementCard(
      row: row,
      localeCode: localeCode,
      titleTrailing: LinkedAgreementOverflowMenu(
        menuKey: Key('provider_detail_agreement_menu_${agreement.id}'),
        actions: linkedAgreementOverflowActions(
          l10n: l10n,
          onEdit: () async {
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
          onUnlink: () async {
            final ok = await confirmUnlinkAgreementWithPaidGuard(
              context: context,
              ref: ref,
              agreement: agreement,
              paidGuardClientName: row.clientName,
              unlinkDialogPartyName: providerName,
              clientId: agreement.clientId,
              providerId: providerId,
            );
            if (ok && context.mounted) await onChanged();
          },
        ),
      ),
    );
  }
}
