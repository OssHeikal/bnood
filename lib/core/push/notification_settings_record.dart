/// Default low-balance threshold from API when no row exists (1_000_000 minor = 10,000 EGP).
const int kDefaultLowBalanceAmountMinor = 1_000_000;

class NotificationSettingsRecord {
  const NotificationSettingsRecord({
    this.pushEnabled = true,
    required this.lowBalanceEnabled,
    required this.lowBalanceAmountMinor,
  });

  /// Account-wide master switch; false stops every push on all devices.
  final bool pushEnabled;
  final bool lowBalanceEnabled;
  final int lowBalanceAmountMinor;

  factory NotificationSettingsRecord.fromDataJson(Map<String, dynamic> json) {
    return NotificationSettingsRecord(
      pushEnabled: json['push_enabled'] != false,
      lowBalanceEnabled: json['low_balance_enabled'] == true,
      lowBalanceAmountMinor: (json['low_balance_amount'] as num?)?.toInt() ?? kDefaultLowBalanceAmountMinor,
    );
  }

  Map<String, dynamic> toPatchJson({bool? pushEnabled, bool? lowBalanceEnabled, int? lowBalanceAmountMinor}) {
    return {
      'push_enabled': ?pushEnabled,
      'low_balance_enabled': ?lowBalanceEnabled,
      'low_balance_amount': ?lowBalanceAmountMinor,
    };
  }
}
