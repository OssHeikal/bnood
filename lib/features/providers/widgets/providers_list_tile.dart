import 'package:flutter/material.dart';

import '../../../core/money/remote_money_units.dart';
import '../../../core/providers_api/app_provider_record.dart';
import '../../../features/suppliers/widgets/directory_person_card.dart';
import '../../../l10n/app_localizations.dart';
import 'remote_craftsman_summary_card.dart';

class ProvidersListTile extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context);
    final kindLabel = provider.type == AppProviderType.supplier
        ? l10n.directorySupplierKindMeta
        : l10n.directoryCraftsmanKindMeta;

    return RemoteCraftsmanSummaryCard(
      name: provider.name,
      accentKey: directoryAccentKeyFor(provider.id),
      localeCode: localeCode,
      kindLabel: kindLabel,
      clientsCount: provider.clientsCount,
      phone: provider.phone,
      paidPiastres: provider.paidMinor,
      remainingPiastres: provider.remainingMinor,
      minorPerMajor: RemoteMoneyUnits.minorPerMajor,
      onTap: onOpenDetail,
      overflowActions: providerOverflowActions(
        l10n: l10n,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}
