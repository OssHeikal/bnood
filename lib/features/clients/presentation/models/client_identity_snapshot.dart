import '../../../../core/domain/ledger/ledger_entities.dart';

class ClientProjectPreviewRow {
  const ClientProjectPreviewRow({
    required this.projectId,
    required this.projectName,
    this.status,
    this.receivedPiastres,
    this.spentPiastres,
    this.remainingPiastres,
  });

  final String projectId;
  final String projectName;
  final String? status;
  final int? receivedPiastres;
  final int? spentPiastres;
  final int? remainingPiastres;
}

class ClientIdentitySnapshot {
  const ClientIdentitySnapshot({
    required this.client,
    this.receivedPiastres,
    this.spentPiastres,
    this.remainingPiastres,
    required this.projects,
    this.projectCount,
    this.usesRemoteMoney = true,
  });

  final Client client;
  final int? receivedPiastres;
  final int? spentPiastres;
  final int? remainingPiastres;
  final List<ClientProjectPreviewRow> projects;
  final int? projectCount;
  final bool usesRemoteMoney;
}