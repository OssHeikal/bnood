import 'package:bnood/core/domain/ledger/ledger_entities.dart';

import '../presentation/models/client_identity_snapshot.dart';
import 'client_api_record.dart';

class OfficeClientDetailRecord {
  OfficeClientDetailRecord({
    required this.client,
    required this.projects,
    this.clientMoney,
  });

  final Client client;
  final List<ClientProjectPreviewRow> projects;
  final ({int received, int spent, int balance})? clientMoney;

  static OfficeClientDetailRecord fromJson(Map<String, dynamic> json) {
    int? readPiastres(Object? raw) {
      if (raw == null) return null;
      if (raw is int) return raw;
      if (raw is num) return raw.round();
      return null;
    }

    final clientJson = json['client'] as Map<String, dynamic>? ?? const {};
    final archivedAtRaw = clientJson['archived_at'];
    final archivedAt = archivedAtRaw == null
        ? null
        : DateTime.parse(archivedAtRaw as String).toUtc();
    final client = Client(
      id: clientJson['id'] as String,
      workspaceId: remoteWorkspaceMarker,
      name: clientJson['name'] as String,
      phone: clientJson['phone'] as String?,
      archivedAt: archivedAt,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );

    final projectsRaw = json['projects'];
    final projects = <ClientProjectPreviewRow>[];
    if (projectsRaw is List) {
      for (final entry in projectsRaw) {
        if (entry is! Map<String, dynamic>) continue;
        final received = readPiastres(entry['received_piastres']);
        final spent = readPiastres(entry['spent_piastres']);
        final balance = readPiastres(entry['balance_piastres']);
        projects.add(
          ClientProjectPreviewRow(
            projectId: entry['id'] as String,
            projectName: entry['name'] as String,
            status: entry['status'] as String?,
            receivedPiastres: received,
            spentPiastres: spent,
            remainingPiastres: balance,
          ),
        );
      }
    }

    final moneyRaw = json['money'] as Map<String, dynamic>?;
    ({int received, int spent, int balance})? clientMoney;
    if (moneyRaw != null) {
      clientMoney = (
        received: readPiastres(moneyRaw['received_piastres']) ?? 0,
        spent: readPiastres(moneyRaw['spent_piastres']) ?? 0,
        balance: readPiastres(moneyRaw['balance_piastres']) ?? 0,
      );
    }

    return OfficeClientDetailRecord(
      client: client,
      projects: projects,
      clientMoney: clientMoney,
    );
  }

  ClientIdentitySnapshot toSnapshot() {
    final money = clientMoney;
    return ClientIdentitySnapshot(
      client: client,
      receivedPiastres: money?.received,
      spentPiastres: money?.spent,
      remainingPiastres: money?.balance,
      projects: projects,
      projectCount: projects.length,
    );
  }
}