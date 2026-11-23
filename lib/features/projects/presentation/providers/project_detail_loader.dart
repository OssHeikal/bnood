import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/core/account/account_context_providers.dart';
import 'package:bnood/core/domain/ledger/ledger_entities.dart';
import 'package:bnood/core/domain/money/money_format.dart';
import 'package:bnood/features/clients/data/client_api_record.dart';
import 'package:bnood/features/clients/data/client_provider_agreement_preview.dart';
import 'package:bnood/features/clients/data/clients_providers.dart';
import 'package:bnood/features/clients/presentation/models/client_detail_snapshot.dart';
import 'package:bnood/features/clients/presentation/models/client_item_spend_rows.dart';
import 'package:bnood/features/clients/presentation/models/client_voucher_movement_lines.dart';
import 'package:bnood/features/home/data/craftsman_snapshot_limit.dart';
import 'package:bnood/features/projects/data/projects_repository.dart';
import 'package:bnood/features/projects/domain/project_detail_params.dart';
import 'package:bnood/features/providers/data/agreements_riverpod.dart';
import 'package:bnood/features/providers/data/app_provider_record.dart';
import 'package:bnood/features/vouchers/data/vouchers_riverpod.dart';

int? _readOptionalInt(Object? raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  if (raw is num) return raw.round();
  return null;
}

Future<ClientDetailSnapshot> loadProjectDetailSnapshot(
  Ref ref,
  ProjectDetailParams params,
) async {
  final clientId = params.clientId;
  final projectId = params.projectId;
  final isOffice = !ref.read(accountContextProvider).isPersonal;

  final record = await ref.read(clientsRepositoryProvider).getClient(clientId);
  var client = record.client;
  var project = record.project;
  var balances = record.balances;

  final needsOfficeProject =
      isOffice && project.id != projectId && !projectId.endsWith(':auto');
  if (needsOfficeProject) {
    final officeJson = await ref
        .read(officeProjectsApiProvider)
        .getProject(projectId);
    final projectJson =
        officeJson['project'] as Map<String, dynamic>? ?? const {};
    final clientJson = officeJson['client'] as Map<String, dynamic>? ?? const {};
    final moneyJson = officeJson['money'] as Map<String, dynamic>?;

    client = Client(
      id: clientJson['id'] as String? ?? clientId,
      workspaceId: remoteWorkspaceMarker,
      name: clientJson['name'] as String? ?? client.name,
      phone: clientJson['phone'] as String?,
      archivedAt: client.archivedAt,
      createdAt: client.createdAt,
      updatedAt: client.updatedAt,
    );
    project = Project(
      id: projectJson['id'] as String? ?? projectId,
      workspaceId: remoteWorkspaceMarker,
      clientId: client.id,
      name: projectJson['name'] as String? ?? project.name,
      unitAddress: null,
      status: projectJson['status'] as String? ?? 'active',
      engineerBasisPoints: _readOptionalInt(projectJson['engineer_basis_points']),
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
    );
    if (moneyJson != null) {
      balances = ClientApiBalances.fromJson({
        'received': moneyJson['received_piastres'],
        'spent': moneyJson['spent_piastres'],
        'remaining': moneyJson['balance_piastres'],
      });
    }
  } else if (project.id != projectId) {
    project = Project(
      id: projectId,
      workspaceId: project.workspaceId,
      clientId: client.id,
      name: project.name,
      unitAddress: project.unitAddress,
      status: project.status,
      engineerBasisPoints: project.engineerBasisPoints,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
    );
  }

  final agreements = await ref
      .read(appAgreementsRepositoryProvider)
      .listAllClientAgreements(clientId);
  final craftsmanPreviews = craftsmanSnapshotRows(
    clientAgreementPreviews(agreements, AppProviderType.craftsman),
  );
  final supplierPreviews = craftsmanSnapshotRows(
    clientAgreementPreviews(agreements, AppProviderType.supplier),
  );
  final craftsmenCount = record.craftsmenCount ?? craftsmanPreviews.length;
  final suppliersCount = record.suppliersCount ?? supplierPreviews.length;

  final itemSpend = await ref
      .read(clientsRepositoryProvider)
      .getClientItemSpend(clientId);
  final itemsCount = itemSpend.items.length;
  final topItems = clientItemRowsFromItemSpend(itemSpend.items.take(3));

  final vouchers = await ref
      .read(vouchersRepositoryProvider)
      .listClientVouchers(clientId: clientId, page: 1, perPage: 5);
  final latestMovements = movementLinesFromVouchers(
    vouchers.items,
    projectId: project.id,
  );

  final spentMinor = balances?.spentPiastres;
  final profit =
      project.engineerBasisPoints == null || spentMinor == null
      ? null
      : MoneyFormat.estimatedProfitPiastres(
          totalSpendPiastres: spentMinor,
          engineerBasisPoints: project.engineerBasisPoints!,
        );

  return ClientDetailSnapshot(
    client: client,
    project: project,
    receivedPiastres: balances?.receivedPiastres,
    spentPiastres: spentMinor,
    estimatedProfitPiastres: profit,
    craftsmanPreviews: craftsmanPreviews,
    supplierPreviews: supplierPreviews,
    craftsmenCount: craftsmenCount,
    suppliersCount: suppliersCount,
    itemsCount: itemsCount,
    movementsCount: vouchers.total,
    topItems: topItems,
    latestMovements: latestMovements,
    onlineIdentityOnly: false,
    usesRemoteMoney: true,
    remainingFromServer: balances?.remainingPiastres,
  );
}