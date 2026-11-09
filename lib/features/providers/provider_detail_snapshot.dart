import '../../core/agreements/app_agreement_record.dart';
import '../../core/providers_api/app_provider_record.dart';

class ProviderDetailClientRow {
  const ProviderDetailClientRow({
    required this.agreement,
    required this.clientName,
  });

  final AppAgreement agreement;
  final String clientName;
}

class ProviderDetailSnapshot {
  const ProviderDetailSnapshot({
    required this.provider,
    this.clientAgreements = const [],
  });

  final AppProvider provider;
  final List<ProviderDetailClientRow> clientAgreements;
}

class ProviderDetailNotFound implements Exception {
  const ProviderDetailNotFound();
}
