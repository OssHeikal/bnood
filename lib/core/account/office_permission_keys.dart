/// Office permission keys aligned with bnood-admin `OfficePermission`.
abstract final class OfficePermissionKeys {
  static const webAccess = 'web_access';

  static const clientsView = 'clients_view';
  static const clientsManage = 'clients_manage';
  static const projectsView = 'projects_view';
  static const projectsManage = 'projects_manage';

  static const clientMoney = 'client_money';

  static const voucherCreate = 'voucher_create';
  static const voucherEdit = 'voucher_edit';
  static const voucherDelete = 'voucher_delete';

  static const itemsManage = 'items_manage';

  static const providersView = 'providers_view';
  static const providersManage = 'providers_manage';
}

/// Logical product areas for UI gating (not 1:1 with API route groups).
enum OfficePermissionArea {
  clients,
  projects,
  items,
  providers,
}

/// Router shell branch order in [StatefulShellRoute] (home, projects, providers, more).
enum ShellNavBranch {
  home(0),
  projects(1),
  providers(2),
  more(3);

  const ShellNavBranch(this.routerIndex);
  final int routerIndex;
}

/// View keys checked on the expanded `/auth/me` `permission_keys` list.
String viewKeyFor(OfficePermissionArea area) => switch (area) {
      OfficePermissionArea.clients => OfficePermissionKeys.clientsView,
      OfficePermissionArea.projects => OfficePermissionKeys.projectsView,
      OfficePermissionArea.items => OfficePermissionKeys.itemsManage,
      OfficePermissionArea.providers => OfficePermissionKeys.providersView,
    };

/// Manage keys for disabling add / edit / delete affordances.
String manageKeyFor(OfficePermissionArea area) => switch (area) {
      OfficePermissionArea.clients => OfficePermissionKeys.clientsManage,
      OfficePermissionArea.projects => OfficePermissionKeys.projectsManage,
      OfficePermissionArea.items => OfficePermissionKeys.itemsManage,
      OfficePermissionArea.providers => OfficePermissionKeys.providersManage,
    };

/// Keys that imply the paired view permission when absent from the payload
/// (matches dashboard behavior for providers; common manage→view elsewhere).
const _viewImpliedByManage = <String, List<String>>{
  OfficePermissionKeys.clientsView: [OfficePermissionKeys.clientsManage],
  OfficePermissionKeys.projectsView: [OfficePermissionKeys.projectsManage],
  OfficePermissionKeys.providersView: [OfficePermissionKeys.providersManage],
};

bool officeKeyGranted(Set<String> keys, String permissionKey) {
  if (keys.contains(permissionKey)) return true;
  final implied = _viewImpliedByManage[permissionKey];
  if (implied == null) return false;
  return implied.any(keys.contains);
}

bool officeCanViewArea(Set<String> keys, OfficePermissionArea area) {
  return officeKeyGranted(keys, viewKeyFor(area));
}

bool officeCanManageArea(Set<String> keys, OfficePermissionArea area) {
  return keys.contains(manageKeyFor(area));
}

bool officeCanViewClientMoney(Set<String> keys) {
  return keys.contains(OfficePermissionKeys.clientMoney);
}

bool officeCanCreateVoucher(Set<String> keys) {
  return keys.contains(OfficePermissionKeys.voucherCreate);
}

bool officeCanEditVoucher(Set<String> keys) {
  return keys.contains(OfficePermissionKeys.voucherEdit);
}

bool officeCanDeleteVoucher(Set<String> keys) {
  return keys.contains(OfficePermissionKeys.voucherDelete);
}