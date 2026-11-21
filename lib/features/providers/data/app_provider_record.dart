enum AppProviderType {
  supplier,
  craftsman,
}

extension AppProviderTypeApi on AppProviderType {
  String get apiValue => switch (this) {
        AppProviderType.supplier => 'supplier',
        AppProviderType.craftsman => 'craftsman',
      };

  static AppProviderType? fromApi(String? raw) => switch (raw) {
        'supplier' => AppProviderType.supplier,
        'craftsman' => AppProviderType.craftsman,
        _ => null,
      };
}

class AppProvider {
  const AppProvider({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.paidMinor,
    this.remainingMinor,
    this.clientsCount,
  });

  final String id;
  final String name;
  final String? phone;
  final AppProviderType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? paidMinor;
  final int? remainingMinor;
  final int? clientsCount;

  static AppProvider fromDataJson(Map<String, dynamic> json) {
    final type = AppProviderTypeApi.fromApi(json['type'] as String?);
    if (type == null) {
      throw FormatException('Unknown provider type: ${json['type']}');
    }

    int? readOptionalMinor(Object? value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.round();
      return null;
    }

    final clientsRaw = json['clients_count'];
    final clientsCount = clientsRaw == null
        ? null
        : clientsRaw is int
            ? clientsRaw
            : clientsRaw is num
                ? clientsRaw.round()
                : null;

    return AppProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      type: type,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
      paidMinor: readOptionalMinor(json['paid']),
      remainingMinor: readOptionalMinor(json['remaining']),
      clientsCount: clientsCount,
    );
  }
}

class ProvidersListPage {
  const ProvidersListPage({
    required this.items,
    required this.page,
    required this.perPage,
    required this.total,
  });

  final List<AppProvider> items;
  final int page;
  final int perPage;
  final int total;

  bool get hasMore => page * perPage < total;
}
