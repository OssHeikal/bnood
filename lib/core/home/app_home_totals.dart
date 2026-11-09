class AppHomeTotals {
  const AppHomeTotals({
    required this.receivedMinor,
    required this.spentMinor,
    required this.remainingMinor,
  });

  final int receivedMinor;
  final int spentMinor;
  final int remainingMinor;

  static AppHomeTotals fromDataJson(Map<String, dynamic> json) {
    int readMinor(Object? raw) {
      if (raw == null) return 0;
      if (raw is int) return raw;
      if (raw is num) return raw.round();
      return 0;
    }

    return AppHomeTotals(
      receivedMinor: readMinor(json['received']),
      spentMinor: readMinor(json['spent']),
      remainingMinor: readMinor(json['remaining']),
    );
  }
}
