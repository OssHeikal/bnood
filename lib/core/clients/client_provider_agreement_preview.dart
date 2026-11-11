import '../agreements/app_agreement_record.dart';
import '../providers_api/app_provider_record.dart';
import '../../features/clients/client_detail_snapshot.dart';
import '../../features/clients/widgets/client_balance_card.dart' show clientAccentKeyFor;

AppProviderType agreementProviderType(AppAgreement agreement) {
  return agreement.providerType ?? AppProviderType.craftsman;
}

ClientCraftsmanPreviewRow clientPreviewRowFromAgreement(
  AppAgreement agreement, {
  required AppProviderType providerType,
}) {
  return ClientCraftsmanPreviewRow(
    craftsmanId: agreement.providerId,
    name: agreement.providerName ?? '—',
    paidPiastres: agreement.paidMinorForDisplay,
    agreedPiastres: agreement.amountMinorForDisplay,
    remainingPiastres: agreement.remainingMinorForDisplay,
    accentKey: clientAccentKeyFor(agreement.providerId),
    agreementId: agreement.id,
    onlineAgreementsOnly: true,
    usesRemoteMoney: true,
    providerType: providerType,
  );
}

List<ClientCraftsmanPreviewRow> clientAgreementPreviews(
  Iterable<AppAgreement> agreements,
  AppProviderType type,
) {
  return agreements
      .where((a) => agreementProviderType(a) == type)
      .map((a) => clientPreviewRowFromAgreement(a, providerType: type))
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));
}
