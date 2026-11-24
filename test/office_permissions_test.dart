import 'package:bnood/core/account/office_membership.dart';
import 'package:bnood/core/account/office_permission_keys.dart';
import 'package:bnood/core/account/office_permissions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OfficeAccountPermissions.personal', () {
    final perms = OfficeAccountPermissions.personal();

    test('allows all areas and money', () {
      expect(perms.canView(OfficePermissionArea.clients), isTrue);
      expect(perms.canManage(OfficePermissionArea.clients), isTrue);
      expect(perms.canViewClientMoney, isTrue);
      expect(perms.canCreateVoucher, isTrue);
      expect(perms.shellBranchVisible(ShellNavBranch.projects), isTrue);
    });
  });

  group('OfficeAccountPermissions.office view-only', () {
    const membership = OfficeMembership(
      id: 'o1',
      name: 'Office',
      readOnly: false,
      permissionKeys: [
        OfficePermissionKeys.webAccess,
        OfficePermissionKeys.clientsView,
        OfficePermissionKeys.projectsView,
        OfficePermissionKeys.providersView,
      ],
    );
    final perms = OfficeAccountPermissions.office(membership);

    test('can view but not manage', () {
      expect(perms.canView(OfficePermissionArea.clients), isTrue);
      expect(perms.canManage(OfficePermissionArea.clients), isFalse);
      expect(perms.canCreateVoucher, isFalse);
      expect(perms.anyLedgerManageEnabled, isFalse);
    });

    test('hides money without client_money', () {
      expect(perms.canViewClientMoney, isFalse);
    });

    test('shell hides only gated tabs', () {
      expect(perms.shellBranchVisible(ShellNavBranch.home), isTrue);
      expect(perms.shellBranchVisible(ShellNavBranch.projects), isTrue);
      expect(perms.shellBranchVisible(ShellNavBranch.providers), isTrue);
    });
  });

  group('implied view from manage keys', () {
    test('clients_manage implies clients_view', () {
      const membership = OfficeMembership(
        id: 'o2',
        name: 'Office',
        readOnly: false,
        permissionKeys: [OfficePermissionKeys.clientsManage],
      );
      final perms = OfficeAccountPermissions.office(membership);
      expect(perms.canView(OfficePermissionArea.clients), isTrue);
      expect(perms.canManage(OfficePermissionArea.clients), isTrue);
    });

    test('providers_manage implies providers_view', () {
      const membership = OfficeMembership(
        id: 'o3',
        name: 'Office',
        readOnly: false,
        permissionKeys: [OfficePermissionKeys.providersManage],
      );
      final perms = OfficeAccountPermissions.office(membership);
      expect(perms.canView(OfficePermissionArea.providers), isTrue);
      expect(perms.canManage(OfficePermissionArea.providers), isTrue);
    });
  });

  group('no view keys', () {
    test('hides projects tab when projects_view missing', () {
      const membership = OfficeMembership(
        id: 'o4',
        name: 'Office',
        readOnly: false,
        permissionKeys: [
          OfficePermissionKeys.webAccess,
          OfficePermissionKeys.clientsView,
        ],
      );
      final perms = OfficeAccountPermissions.office(membership);
      expect(perms.shellBranchVisible(ShellNavBranch.projects), isFalse);
      expect(perms.shellBranchVisible(ShellNavBranch.providers), isFalse);
    });
  });

  group('read-only office', () {
    test('blocks manage even with manage keys', () {
      const membership = OfficeMembership(
        id: 'o5',
        name: 'Office',
        readOnly: true,
        permissionKeys: [OfficePermissionKeys.clientsManage],
      );
      final perms = OfficeAccountPermissions.office(membership);
      expect(perms.canManage(OfficePermissionArea.clients), isFalse);
      expect(perms.canCreateVoucher, isFalse);
    });
  });
}