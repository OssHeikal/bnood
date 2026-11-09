import 'app_home_totals.dart';

class AppHomeClientPreview {
  const AppHomeClientPreview({
    required this.id,
    required this.name,
    required this.receivedMinor,
    required this.spentMinor,
    required this.remainingMinor,
  });

  final String id;
  final String name;
  final int receivedMinor;
  final int spentMinor;
  final int remainingMinor;

  static AppHomeClientPreview fromJson(Map<String, dynamic> json) {
    int readMinor(Object? raw) {
      if (raw == null) return 0;
      if (raw is int) return raw;
      if (raw is num) return raw.round();
      return 0;
    }

    return AppHomeClientPreview(
      id: json['id'] as String,
      name: json['name'] as String,
      receivedMinor: readMinor(json['received']),
      spentMinor: readMinor(json['spent']),
      remainingMinor: readMinor(json['remaining']),
    );
  }
}

class AppHomeCraftsmanPreview {
  const AppHomeCraftsmanPreview({
    required this.id,
    required this.name,
    this.lastActivityAt,
    this.paidMinor = 0,
    this.remainingMinor,
    this.clientsCount = 0,
  });

  final String id;
  final String name;
  final DateTime? lastActivityAt;
  final int paidMinor;
  final int? remainingMinor;
  final int clientsCount;

  static AppHomeCraftsmanPreview fromJson(Map<String, dynamic> json) {
    DateTime? activity;
    final raw = json['last_activity_at'];
    if (raw is String && raw.isNotEmpty) {
      activity = DateTime.tryParse(raw);
    }

    int readMinor(Object? value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.round();
      return 0;
    }

    int? readNullableMinor(Object? value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.round();
      return null;
    }

    final clientsRaw = json['clients_count'];
    final clientsCount = clientsRaw is int
        ? clientsRaw
        : clientsRaw is num
            ? clientsRaw.round()
            : 0;

    return AppHomeCraftsmanPreview(
      id: json['id'] as String,
      name: json['name'] as String,
      lastActivityAt: activity,
      paidMinor: readMinor(json['paid']),
      remainingMinor: readNullableMinor(json['remaining']),
      clientsCount: clientsCount,
    );
  }
}

class AppHomeDashboard {
  const AppHomeDashboard({
    required this.totals,
    required this.clients,
    required this.craftsmen,
  });

  final AppHomeTotals totals;
  final List<AppHomeClientPreview> clients;
  final List<AppHomeCraftsmanPreview> craftsmen;

  static AppHomeDashboard fromDataJson(Map<String, dynamic> json) {
    final clientsRaw = json['clients'];
    final craftsmenRaw = json['craftsmen'];
    final clients = clientsRaw is List
        ? clientsRaw
            .map((e) => AppHomeClientPreview.fromJson(e as Map<String, dynamic>))
            .toList()
        : const <AppHomeClientPreview>[];
    final craftsmen = craftsmenRaw is List
        ? craftsmenRaw
            .map((e) => AppHomeCraftsmanPreview.fromJson(e as Map<String, dynamic>))
            .toList()
        : const <AppHomeCraftsmanPreview>[];

    return AppHomeDashboard(
      totals: AppHomeTotals.fromDataJson(json),
      clients: clients,
      craftsmen: craftsmen,
    );
  }
}
