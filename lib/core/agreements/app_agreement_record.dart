class AppAgreement {
  const AppAgreement({
    required this.id,
    required this.clientId,
    required this.providerId,
    required this.amountPiastres,
    this.clientName,
    this.providerName,
  });

  final String id;
  final String clientId;
  final String providerId;

  /// `null` = linked but no agreed amount; `0` = explicitly zero agreed.
  final int? amountPiastres;

  final String? clientName;
  final String? providerName;

  bool get hasAgreedAmount => amountPiastres != null;

  static AppAgreement fromDataJson(Map<String, dynamic> json) {
    final amountRaw = json.containsKey('amount') ? json['amount'] : null;
    int? amountPiastres;
    if (amountRaw != null && amountRaw is num) {
      amountPiastres = amountRaw.toInt();
    }

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
