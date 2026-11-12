import 'provider_detail_snapshot.dart';

/// Aggregated المتفق عليه / مدفوع / المتبقي across linked client agreements.
class ProviderAgreementTotals {
  const ProviderAgreementTotals({
    this.agreedMinor,
    required this.paidMinor,
    this.remainingMinor,
  });

  final int? agreedMinor;
  final int paidMinor;
  final int? remainingMinor;
}

ProviderAgreementTotals aggregateProviderAgreements(List<ProviderDetailClientRow> rows) {
  var agreedMinor = 0;
  var hasAgreed = false;
  var paidMinor = 0;
  var remainingMinor = 0;
  var hasRemaining = false;

  for (final row in rows) {
    final agreement = row.agreement;
    final amountMinor = agreement.amountMinorForDisplay;
    if (amountMinor != null) {
      agreedMinor += amountMinor;
      hasAgreed = true;
    }
    paidMinor += agreement.paidMinorForDisplay;
    final remaining = agreement.remainingMinorForDisplay;
    if (remaining != null) {
      remainingMinor += remaining;
      hasRemaining = true;
    }
  }

  return ProviderAgreementTotals(
    agreedMinor: hasAgreed ? agreedMinor : null,
    paidMinor: paidMinor,
    remainingMinor: hasRemaining ? remainingMinor : null,
  );
}
