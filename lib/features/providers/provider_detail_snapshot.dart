import '../../core/agreements/app_agreement_record.dart';
import '../../core/providers_api/app_provider_record.dart';
import '../../core/vouchers/app_voucher_record.dart';

class ProviderDetailClientRow {
  const ProviderDetailClientRow({
    required this.agreement,
    required this.clientName,
  });

  final AppAgreement agreement;
  final String clientName;
}

class ProviderDetailVoucherRow {
  const ProviderDetailVoucherRow({
    required this.voucher,
    required this.clientName,
  });

  final AppVoucher voucher;
  final String clientName;
}

class ProviderDetailSnapshot {
  const ProviderDetailSnapshot({
    required this.provider,
    this.clientAgreements = const [],
    this.voucherHistory = const [],
    this.totalVoucherMinor = 0,
  });

  final AppProvider provider;
  final List<ProviderDetailClientRow> clientAgreements;
  final List<ProviderDetailVoucherRow> voucherHistory;
  final int totalVoucherMinor;
}

class ProviderDetailNotFound implements Exception {
  const ProviderDetailNotFound();
}
