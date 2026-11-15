/// Default low-balance threshold from API when no row exists (1_000_000 minor = 10,000 EGP).
const int kDefaultLowBalanceAmountMinor = 1_000_000;

class NotificationSettingsRecord {
  const NotificationSettingsRecord({
    required this.lowBalanceEnabled,
    required this.lowBalanceAmountMinor,
  });

  final bool lowBalanceEnabled;
  final int lowBalanceAmountMinor;

  factory NotificationSettingsRecord.fromDataJson(Map<String, dynamic> json) {
    return NotificationSettingsRecord(
      lowBalanceEnabled: json['low_balance_enabled'] == true,
      lowBalanceAmountMinor: (json['low_balance_amount'] as num?)?.toInt() ?? kDefaultLowBalanceAmountMinor,
    );
  }

  Map<String, dynamic> toPatchJson({
    bool? lowBalanceEnabled,
    int? lowBalanceAmountMinor,
  }) {
    return {
      if (lowBalanceEnabled != null) 'low_balance_enabled': lowBalanceEnabled,
      if (lowBalanceAmountMinor != null) 'low_balance_amount': lowBalanceAmountMinor,
    };
  }
}