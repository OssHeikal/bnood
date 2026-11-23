import 'office_membership.dart';

/// Offices the user owns (Business owner); locks the app to office-only context.
OfficeMembership? primaryOwnedOffice(List<OfficeMembership> offices) {
  final owned = offices.where((o) => o.isOwner).toList();
  if (owned.isEmpty) return null;
  if (owned.length == 1) return owned.single;
  owned.sort((a, b) => a.name.compareTo(b.name));
  return owned.first;
}

bool userLocksToOwnedOffice(List<OfficeMembership> offices) =>
    primaryOwnedOffice(offices) != null;