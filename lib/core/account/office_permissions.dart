import 'office_membership.dart';
import 'office_permission_keys.dart';

/// Resolved permission flags for the active account scope.
final class OfficeAccountPermissions {
  const OfficeAccountPermissions._({
    required this.isPersonal,
    required this.officeReadOnly,
    required this.keys,
    required this.legacyUnrestricted,
  });

  factory OfficeAccountPermissions.personal() {
    return const OfficeAccountPermissions._(
      isPersonal: true,
      officeReadOnly: false,
      keys: {},
      legacyUnrestricted: true,
    );
  }

  factory OfficeAccountPermissions.office(OfficeMembership? membership) {
    if (membership == null) {
      return const OfficeAccountPermissions._(
        isPersonal: false,
        officeReadOnly: false,
        keys: {},
        legacyUnrestricted: true,
      );
    }
    final raw = membership.permissionKeys;
    final legacy = raw == null;
    final keySet = legacy ? <String>{} : Set<String>.from(raw);
    return OfficeAccountPermissions._(
      isPersonal: false,
      officeReadOnly: membership.isReadOnly,
      keys: keySet,
      legacyUnrestricted: legacy,
    );
  }

  final bool isPersonal;
  final bool officeReadOnly;
  final Set<String> keys;
  final bool legacyUnrestricted;

  bool _granted(String key) =>
      legacyUnrestricted || officeKeyGranted(keys, key);

  bool canView(OfficePermissionArea area) =>
      isPersonal || _granted(viewKeyFor(area));

  bool canManage(OfficePermissionArea area) {
    if (isPersonal) return true;
    if (officeReadOnly || legacyUnrestricted) {
      return !officeReadOnly;
    }
    return officeCanManageArea(keys, area);
  }

  bool get canViewClientMoney =>
      isPersonal || _granted(OfficePermissionKeys.clientMoney);

  bool get canCreateVoucher {
    if (isPersonal) return true;
    if (officeReadOnly) return false;
    if (legacyUnrestricted) return true;
    return officeCanCreateVoucher(keys);
  }

  bool get canEditVoucher {
    if (isPersonal) return true;
    if (officeReadOnly) return false;
    if (legacyUnrestricted) return true;
    return officeCanEditVoucher(keys);
  }

  bool get canDeleteVoucher {
    if (isPersonal) return true;
    if (officeReadOnly) return false;
    if (legacyUnrestricted) return true;
    return officeCanDeleteVoucher(keys);
  }

  bool shellBranchVisible(ShellNavBranch branch) {
    if (isPersonal) return true;
    return switch (branch) {
      ShellNavBranch.home => true,
      ShellNavBranch.projects => canView(OfficePermissionArea.projects),
      ShellNavBranch.providers => canView(OfficePermissionArea.providers),
      ShellNavBranch.more => true,
    };
  }

  /// Any ledger mutation (backward-compatible coarse gate).
  bool get anyLedgerManageEnabled {
    if (isPersonal) return true;
    if (officeReadOnly) return false;
    if (legacyUnrestricted) return true;
    return canManage(OfficePermissionArea.clients) ||
        canManage(OfficePermissionArea.projects) ||
        canCreateVoucher ||
        canManage(OfficePermissionArea.items) ||
        canManage(OfficePermissionArea.providers);
  }
}