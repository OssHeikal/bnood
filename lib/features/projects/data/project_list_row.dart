import 'package:bnood/features/clients/data/client_api_record.dart';
import 'package:bnood/features/home/data/home_row_models.dart';

import 'office_project_record.dart';

class ProjectListRow {
  const ProjectListRow({
    required this.projectId,
    required this.projectName,
    required this.clientId,
    required this.clientName,
    this.remainingPiastres,
    this.receivedPiastres,
    this.spentPiastres,
  });

  final String projectId;
  final String projectName;
  final String clientId;
  final String clientName;
  final int? remainingPiastres;
  final int? receivedPiastres;
  final int? spentPiastres;
}

ProjectListRow projectListRowFromClientRecord(ClientApiRecord record) {
  final balances = record.balances;
  return ProjectListRow(
    projectId: record.project.id,
    projectName: record.project.name,
    clientId: record.client.id,
    clientName: record.client.name,
    remainingPiastres: balances?.remainingPiastres,
    receivedPiastres: balances?.receivedPiastres,
    spentPiastres: balances?.spentPiastres,
  );
}

ProjectListRow projectListRowFromOfficeRecord(OfficeProjectRecord record) {
  return ProjectListRow(
    projectId: record.projectId,
    projectName: record.projectName,
    clientId: record.clientId,
    clientName: record.clientName,
    remainingPiastres: record.balancePiastres,
    receivedPiastres: record.receivedPiastres,
    spentPiastres: record.spentPiastres,
  );
}

ProjectListRow projectListRowFromBalanceRow(HomeClientBalanceRow row) {
  final project = row.project;
  return ProjectListRow(
    projectId: project?.id ?? row.client.id,
    projectName: project?.name ?? row.client.name,
    clientId: row.client.id,
    clientName: row.client.name,
    remainingPiastres: row.remainingPiastres,
    receivedPiastres: row.receivedPiastres,
    spentPiastres: row.spentPiastres,
  );
}