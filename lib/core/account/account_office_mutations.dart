import 'office_membership.dart';
import 'office_permission_keys.dart';

/// Whether create/edit ledger actions are allowed for the active account scope.
bool accountOfficeMutationsEnabled({
  required bool isPersonal,
  OfficeMembership? selectedOffice,
}) {
  if (isPersonal) return true;
  if (selectedOffice == null) return true;
  if (selectedOffice.isReadOnly) return false;
  final keys = selectedOffice.permissionKeys;
  if (keys == null) return true;
  return officeRoleAllowsLedgerCreates(keys);
}

bool officeMembershipListContains(
  List<OfficeMembership> offices,
  String officeId,
) {
  return offices.any((o) => o.id == officeId);
}