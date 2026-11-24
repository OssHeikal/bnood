import 'office_membership.dart';
import 'office_permission_keys.dart';
import 'office_permissions.dart';

/// Whether any create/manage ledger action is allowed for the active account scope.
bool accountOfficeMutationsEnabled({
  required bool isPersonal,
  OfficeMembership? selectedOffice,
}) {
  final perms = isPersonal
      ? OfficeAccountPermissions.personal()
      : OfficeAccountPermissions.office(selectedOffice);
  return perms.anyLedgerManageEnabled;
}

/// Area-specific manage gate (add / edit / delete).
bool accountOfficeCanManage({
  required bool isPersonal,
  OfficeMembership? selectedOffice,
  required OfficePermissionArea area,
}) {
  if (isPersonal) return true;
  return OfficeAccountPermissions.office(selectedOffice).canManage(area);
}

bool officeMembershipListContains(
  List<OfficeMembership> offices,
  String officeId,
) {
  return offices.any((o) => o.id == officeId);
}