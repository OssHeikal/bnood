import '../agreements/app_agreement_record.dart';
import '../providers_api/app_provider_record.dart';
import '../../features/clients/client_detail_snapshot.dart';
import '../../features/clients/widgets/client_balance_card.dart' show clientAccentKeyFor;

/// Whether [agreement] belongs to [kind] for assignments and roster diffing.
///
/// Uses [agreement.providerType] when set. When missing, membership is inferred
/// only from [kindProviderIds] (the roster for that kind). Agreements whose
/// provider is not in the roster are not treated as belonging to either kind.
bool agreementMatchesProviderKind(
  AppAgreement agreement,
  AppProviderType kind, {
  required Set<String> kindProviderIds,
}) {
  final explicit = agreement.providerType;
  if (explicit != null) return explicit == kind;
  return kindProviderIds.contains(agreement.providerId);
}

List<AppAgreement> clientAgreementsForKind(
  Iterable<AppAgreement> agreements,
  AppProviderType kind, {
  required Set<String> kindProviderIds,
}) {
  return agreements
      .where((a) => agreementMatchesProviderKind(a, kind, kindProviderIds: kindProviderIds))
      .toList();
}

/// Agreements to remove when saving an assignments sheet for one provider kind.
/// Deletes when saving provider→client assignments (input must be this provider only).
Iterable<AppAgreement> providerAgreementsToDeleteOnAssignmentsSave({
  required Iterable<AppAgreement> providerAgreements,
  required Set<String> selectedClientIds,
}) {
  return providerAgreements.where((a) => !selectedClientIds.contains(a.clientId));
}

List<AppAgreement> agreementsBelongingToProvider(
  Iterable<AppAgreement> agreements,
  String providerId,
) {
  return agreements.where((a) => a.providerId == providerId).toList();
}

Iterable<AppAgreement> clientAgreementsToDeleteOnAssignmentsSave({
  required Iterable<AppAgreement> allAgreements,
  required AppProviderType kind,
  required Set<String> kindProviderIds,
  required Set<String> selectedProviderIds,
}) {
  return clientAgreementsForKind(
    allAgreements,
    kind,
    kindProviderIds: kindProviderIds,
  ).where((a) => !selectedProviderIds.contains(a.providerId));
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
  AppProviderType type, {
  Set<String>? kindProviderIds,
}) {
  final ids = kindProviderIds ?? const <String>{};
  return agreements
      .where((a) => agreementMatchesProviderKind(
            a,
            type,
            kindProviderIds: kindProviderIds ?? ids,
          ))
      .map((a) => clientPreviewRowFromAgreement(a, providerType: type))
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));
}
