import '../money/remote_money_units.dart';

class AppAgreement {
  const AppAgreement({
    required this.id,
    required this.clientId,
    required this.providerId,
    required this.amountPiastres,
    this.amountMajor,
    this.paidMajor,
    this.remainingMajor,
    this.clientName,
    this.providerName,
  });

  final String id;
  final String clientId;
  final String providerId;

  /// Local Drift rows: integer piastres (÷100). Online API: minor units (÷100) when [amountMajor] is set.
  final int? amountPiastres;

  /// Online agreement amount in EGP major units (`null` = unset).
  final double? amountMajor;

  /// Labor paid to craftsman (materials excluded), major EGP.
  final double? paidMajor;

  /// Signed remaining in major EGP; `null` when [amountMajor] is `null`.
  final double? remainingMajor;

  final String? clientName;
  final String? providerName;

  bool get hasAgreedAmount => amountMajor != null || amountPiastres != null;

  int? get amountMinorForDisplay {
    if (amountMajor != null) return RemoteMoneyUnits.majorToMinor(amountMajor!);
    return amountPiastres;
  }

  int get paidMinorForDisplay =>
      paidMajor == null ? 0 : RemoteMoneyUnits.majorToMinor(paidMajor!);

  int? get remainingMinorForDisplay {
    if (amountMajor == null && amountPiastres == null) return null;
    if (remainingMajor != null) return RemoteMoneyUnits.majorToMinor(remainingMajor!);
    return null;
  }

  static double? _readMajor(Object? raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return null;
  }

  static AppAgreement fromDataJson(Map<String, dynamic> json) {
    final amountRaw = json.containsKey('amount') ? json['amount'] : null;
    final amountMajor = _readMajor(amountRaw);
    int? amountPiastres;
    if (amountMajor != null) {
      amountPiastres = RemoteMoneyUnits.majorToMinor(amountMajor);
    } else if (amountRaw != null && amountRaw is num) {
      amountPiastres = amountRaw.toInt();
    }

    final paidMajor = _readMajor(json['paid']);
    final remainingMajor = _readMajor(json['remaining']);

    String? clientName;
    final client = json['client'];
    if (client is Map<String, dynamic>) {
      clientName = client['name'] as String?;
    }

    String? providerName;
    final provider = json['provider'];
    if (provider is Map<String, dynamic>) {
      providerName = provider['name'] as String?;
    }

    return AppAgreement(
      id: json['id'] as String,
      clientId: json['client_id'] as String? ?? (client is Map ? client['id'] as String : ''),
      providerId: json['provider_id'] as String? ?? (provider is Map ? provider['id'] as String : ''),
      amountPiastres: amountPiastres,
      amountMajor: amountMajor,
      paidMajor: paidMajor,
      remainingMajor: remainingMajor,
      clientName: clientName,
      providerName: providerName,
    );
  }
}

class AgreementsListPage {
  const AgreementsListPage({
    required this.items,
    required this.page,
    required this.perPage,
    required this.total,
  });

  final List<AppAgreement> items;
  final int page;
  final int perPage;
  final int total;

  bool get hasMore => page * perPage < total;
}
