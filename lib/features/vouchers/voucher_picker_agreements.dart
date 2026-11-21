import '../../core/agreements/app_agreement_record.dart';
import '../../core/money/ledger_math.dart';
import '../../core/providers_api/app_provider_record.dart';
import '../../core/repositories/bnood_repository.dart';

class VoucherPickerAgreementContext {
  const VoucherPickerAgreementContext({
    required this.linkedIds,
    required this.remainingByProviderId,
  });

  final Set<String> linkedIds;
  final Map<String, int> remainingByProviderId;
}

VoucherPickerAgreementContext remoteAgreementContext(
  Iterable<AppAgreement> agreements,
  AppProviderType kind,
) {
  final linked = <String>{};
  final remaining = <String, int>{};
  for (final agreement in agreements) {
    final type = agreement.providerType;
    if (type != null && type != kind) continue;
    linked.add(agreement.providerId);
    final rem = agreement.remainingMinorForDisplay;
    if (rem != null) {
      remaining[agreement.providerId] = rem;
    }
  }
  return VoucherPickerAgreementContext(linkedIds: linked, remainingByProviderId: remaining);
}

Future<VoucherPickerAgreementContext> localCraftsmanAgreementContext(
  BnoodRepository repo,
  String projectId,
) async {
  final agreements = await repo.agreementsForProject(projectId);
  final tx = await repo.transactionsForProject(projectId);
  final linked = agreements.map((a) => a.craftsmanId).toSet();
  final remaining = <String, int>{};
  for (final agreement in agreements) {
    final paid = LedgerMath.craftsmanPaidPiastres(rows: tx, craftsmanId: agreement.craftsmanId);
    final rem = LedgerMath.craftsmanRemainingPiastres(
      initialAmountPiastres: agreement.initialAmountPiastres,
      paidPiastres: paid,
    );
    if (rem != null) {
      remaining[agreement.craftsmanId] = rem;
    }
  }
  return VoucherPickerAgreementContext(linkedIds: linked, remainingByProviderId: remaining);
}