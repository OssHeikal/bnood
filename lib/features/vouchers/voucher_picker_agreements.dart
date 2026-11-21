import '../../core/agreements/app_agreement_record.dart';
import '../../core/providers_api/app_provider_record.dart';

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
