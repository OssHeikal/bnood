import 'package:bnood/features/clients/data/client_api_record.dart';
import 'package:bnood/features/clients/presentation/models/client_identity_snapshot.dart';

ClientIdentitySnapshot clientIdentityFromApiRecord(ClientApiRecord record) {
  final balances = record.balances;
  final projects = _projectRowsFromRecord(record);
  return ClientIdentitySnapshot(
    client: record.client,
    receivedPiastres: balances?.receivedPiastres,
    spentPiastres: balances?.spentPiastres,
    remainingPiastres: balances?.remainingPiastres,
    projects: projects,
    projectCount: projects.length,
  );
}

List<ClientProjectPreviewRow> _projectRowsFromRecord(ClientApiRecord record) {
  return [
    ClientProjectPreviewRow(
      projectId: record.project.id,
      projectName: record.project.name,
      status: record.project.status,
      receivedPiastres: record.balances?.receivedPiastres,
      spentPiastres: record.balances?.spentPiastres,
      remainingPiastres: record.balances?.remainingPiastres,
    ),
  ];
}

List<ClientProjectPreviewRow> clientProjectPreviewsFromClientJson(
  Map<String, dynamic> json,
) {
  int? readPiastres(Object? raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.round();
    return null;
  }

  final balancesRaw = json['balances'];
  int? received;
  int? spent;
  int? remaining;
  if (balancesRaw is Map<String, dynamic>) {
    received = readPiastres(balancesRaw['received']);
    spent = readPiastres(balancesRaw['spent']);
    remaining = readPiastres(balancesRaw['remaining']);
  }

  final projectsRaw = json['projects'];
  if (projectsRaw is List && projectsRaw.isNotEmpty) {
    return [
      for (final entry in projectsRaw)
        if (entry is Map<String, dynamic>)
          ClientProjectPreviewRow(
            projectId: entry['id'] as String,
            projectName: entry['name'] as String,
            status: entry['status'] as String?,
            receivedPiastres: received,
            spentPiastres: spent,
            remainingPiastres: remaining,
          ),
    ];
  }

  final record = ClientApiRecord.fromDataJson(json);
  return _projectRowsFromRecord(record);
}