import 'package:bnood/core/domain/ledger/ledger_entities.dart';

import '../../clients/data/client_api_record.dart';

class OfficeProjectRecord {
  const OfficeProjectRecord({
    required this.projectId,
    required this.projectName,
    required this.clientId,
    required this.clientName,
    this.status,
    this.receivedPiastres,
    this.spentPiastres,
    this.balancePiastres,
  });

  final String projectId;
  final String projectName;
  final String clientId;
  final String clientName;
  final String? status;
  final int? receivedPiastres;
  final int? spentPiastres;
  final int? balancePiastres;

  static OfficeProjectRecord fromJson(Map<String, dynamic> json) {
    int? readPiastres(Object? raw) {
      if (raw == null) return null;
      if (raw is int) return raw;
      if (raw is num) return raw.round();
      return null;
    }

    final clientId = json['client_id'] as String? ?? '';
    final clientName = json['client_name'] as String? ?? '';

    return OfficeProjectRecord(
      projectId: json['id'] as String,
      projectName: json['name'] as String,
      clientId: clientId,
      clientName: clientName,
      status: json['status'] as String?,
      receivedPiastres: readPiastres(json['received_piastres']),
      spentPiastres: readPiastres(json['spent_piastres']),
      balancePiastres: readPiastres(json['balance_piastres']),
    );
  }

  Project toProject() {
    return Project(
      id: projectId,
      workspaceId: remoteWorkspaceMarker,
      clientId: clientId,
      name: projectName,
      unitAddress: null,
      status: status ?? 'active',
      engineerBasisPoints: null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  Client toClient() {
    return Client(
      id: clientId,
      workspaceId: remoteWorkspaceMarker,
      name: clientName,
      phone: null,
      archivedAt: null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

class ProjectsListPage {
  const ProjectsListPage({
    required this.items,
    required this.page,
    required this.perPage,
    required this.total,
  });

  final List<OfficeProjectRecord> items;
  final int page;
  final int perPage;
  final int total;

  bool get hasMore => page * perPage < total;
}