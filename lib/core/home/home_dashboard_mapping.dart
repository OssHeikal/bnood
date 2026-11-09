import '../clients/client_api_record.dart';
import '../database/database.dart';
import '../repositories/bnood_repository.dart';
import 'app_home_dashboard.dart';

HomeClientBalanceRow homeClientBalanceRowFromPreview(AppHomeClientPreview preview) {
  final stamp = DateTime.utc(2026, 1, 1);
  return HomeClientBalanceRow(
    client: Client(
      id: preview.id,
      workspaceId: remoteWorkspaceMarker,
      name: preview.name,
      phone: '',
      createdAt: stamp,
      updatedAt: stamp,
    ),
    receivedPiastres: preview.receivedMinor,
    spentPiastres: preview.spentMinor,
    remainingPiastres: preview.remainingMinor,
  );
}

HomeCraftsmanActivityRow homeCraftsmanRowFromPreview(AppHomeCraftsmanPreview preview) {
  final activity = preview.lastActivityAt ?? DateTime.utc(2026, 1, 1);
  return HomeCraftsmanActivityRow(
    craftsman: CraftsmenData(
      id: preview.id,
      workspaceId: remoteWorkspaceMarker,
      name: preview.name,
      phone: '',
      createdAt: activity,
      updatedAt: activity,
    ),
    paidPiastres: preview.paidMinor,
    lastLaborAt: activity,
    remainingPiastres: preview.remainingMinor,
    clientsCount: preview.clientsCount,
  );
}
