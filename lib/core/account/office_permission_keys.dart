/// Office role permission keys aligned with bnood-admin `OfficePermission`.
abstract final class OfficePermissionKeys {
  static const clientsManage = 'clients_manage';
  static const projectsManage = 'projects_manage';
  static const voucherCreate = 'voucher_create';
  static const itemsManage = 'items_manage';
  static const providersManage = 'providers_manage';

  static const ledgerCreateKeys = <String>{
    clientsManage,
    projectsManage,
    voucherCreate,
    itemsManage,
    providersManage,
  };
}

/// Any create/manage key — used to disable add actions when none are granted.
bool officeRoleAllowsLedgerCreates(List<String> permissionKeys) {
  if (permissionKeys.isEmpty) return false;
  return permissionKeys.any(OfficePermissionKeys.ledgerCreateKeys.contains);
}