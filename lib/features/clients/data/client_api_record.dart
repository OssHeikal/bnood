import 'package:bnood/core/domain/ledger/ledger_entities.dart';

/// Parsed client payload from `/api/v1/clients` including the hidden project.
class ClientApiRecord {
  const ClientApiRecord({
    required this.client,
    required this.project,
    this.balances,
    this.craftsmenCount,
    this.suppliersCount,
  });

  final Client client;
  final Project project;
  final ClientApiBalances? balances;
  final int? craftsmenCount;
  final int? suppliersCount;

  static ClientApiRecord fromDataJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final createdAt = DateTime.parse(json['created_at'] as String).toUtc();
    final updatedAt = DateTime.parse(json['updated_at'] as String).toUtc();
    final archivedRaw = json['archived_at'];
    final archivedAt = archivedRaw == null
        ? null
        : DateTime.parse(archivedRaw as String).toUtc();

    final client = Client(
      id: id,
      workspaceId: remoteWorkspaceMarker,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      archivedAt: archivedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    int? readOptionalInt(Object? raw) {
      if (raw == null) return null;
      if (raw is int) return raw;
      if (raw is num) return raw.round();
      return null;
    }

    final projectJson = _resolveProjectJson(json, id: id, name: client.name);

    final project = Project(
      id: projectJson['id'] as String,
      workspaceId: remoteWorkspaceMarker,
      clientId: id,
      name: projectJson['name'] as String,
      unitAddress: null,
      status: projectJson['status'] as String? ?? 'active',
      engineerBasisPoints: readOptionalInt(
        projectJson['engineer_basis_points'],
      ),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    final balancesRaw = json['balances'];
    final ClientApiBalances? balances = balancesRaw == null
        ? null
        : ClientApiBalances.fromJson(balancesRaw);

    return ClientApiRecord(
      client: client,
      project: project,
      balances: balances,
      craftsmenCount: readOptionalInt(json['craftsmen_count']),
      suppliersCount: readOptionalInt(json['suppliers_count']),
    );
  }
}

/// Placeholder workspace id for API-sourced rows (not persisted in Drift).
const remoteWorkspaceMarker = 'remote';

class ClientApiBalances {
  const ClientApiBalances({
    this.receivedPiastres,
    this.spentPiastres,
    this.remainingPiastres,
  });

  final int? receivedPiastres;
  final int? spentPiastres;
  final int? remainingPiastres;

  factory ClientApiBalances.fromJson(Object? json) {
    if (json == null) return const ClientApiBalances();
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Unexpected balances shape');
    }
    int? readBalance(Object? raw) {
      if (raw == null) return null;
      if (raw is int) return raw;
      if (raw is num) return raw.round();
      return null;
    }

    return ClientApiBalances(
      receivedPiastres: readBalance(json['received']),
      spentPiastres: readBalance(json['spent']),
      remainingPiastres: readBalance(json['remaining']),
    );
  }
}

Map<String, dynamic> _resolveProjectJson(
  Map<String, dynamic> json, {
  required String id,
  required String name,
}) {
  final direct = json['project'];
  if (direct is Map<String, dynamic>) return direct;

  final projects = json['projects'];
  if (projects is List) {
    for (final entry in projects) {
      if (entry is Map<String, dynamic>) return entry;
    }
  }

  return {
    'id': '$id:auto',
    'name': name,
    'status': 'active',
    'engineer_basis_points': null,
  };
}

class ClientsListPage {
  const ClientsListPage({
    required this.items,
    required this.page,
    required this.perPage,
    required this.total,
  });

  final List<ClientApiRecord> items;
  final int page;
  final int perPage;
  final int total;

  bool get hasMore => page * perPage < total;
}
