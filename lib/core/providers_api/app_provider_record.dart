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
  });

  final String id;
  final String name;
  final String? phone;
  final AppProviderType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  static AppProvider fromDataJson(Map<String, dynamic> json) {
    final type = AppProviderTypeApi.fromApi(json['type'] as String?);
    if (type == null) {
      throw FormatException('Unknown provider type: ${json['type']}');
    }
    return AppProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      type: type,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
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
