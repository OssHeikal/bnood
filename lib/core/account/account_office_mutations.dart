import 'office_membership.dart';

/// Whether create/edit ledger actions are allowed for the active account scope.
bool accountOfficeMutationsEnabled({
  required bool isPersonal,
  OfficeMembership? selectedOffice,
}) {
  if (isPersonal) return true;
  if (selectedOffice == null) return true;
  return !selectedOffice.isReadOnly;
}

bool officeMembershipListContains(
  List<OfficeMembership> offices,
  String officeId,
) {
  return offices.any((o) => o.id == officeId);
}