import '../money/remote_money_units.dart';

/// Convert UI minor units (remote scale) to API major EGP for agreements.
double? agreementAmountMajorFromMinor(int? amountMinor) {
  if (amountMinor == null) return null;
  return RemoteMoneyUnits.minorToMajor(amountMinor);
}
