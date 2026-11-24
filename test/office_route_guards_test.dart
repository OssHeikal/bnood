import 'package:bnood/core/account/office_membership.dart';
import 'package:bnood/core/account/office_permission_keys.dart';
import 'package:bnood/core/account/office_permissions.dart';
import 'package:bnood/core/account/office_route_guards.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('officePermissionRedirectForScope', () {
    test('personal account never redirects', () {
      final perms = OfficeAccountPermissions.personal();
      expect(
        officePermissionRedirectForScope(
          isPersonal: true,
          perms: perms,
          location: '/clients',
        ),
        isNull,
      );
    });

    test('redirects clients without view', () {
      final perms = OfficeAccountPermissions.office(
        const OfficeMembership(
          id: 'office-1',
          name: 'Office',
          readOnly: false,
          permissionKeys: [OfficePermissionKeys.webAccess],
        ),
      );
      expect(
        officePermissionRedirectForScope(
          isPersonal: false,
          perms: perms,
          location: '/clients',
        ),
        '/home',
      );
    });

    test('redirects statement without client_money', () {
      final perms = OfficeAccountPermissions.office(
        const OfficeMembership(
          id: 'office-1',
          name: 'Office',
          readOnly: false,
          permissionKeys: [
            OfficePermissionKeys.clientsView,
            OfficePermissionKeys.webAccess,
          ],
        ),
      );
      expect(
        officePermissionRedirectForScope(
          isPersonal: false,
          perms: perms,
          location: '/clients/c1/statement',
        ),
        '/home',
      );
    });

    test('allows statement with money and clients view', () {
      final perms = OfficeAccountPermissions.office(
        const OfficeMembership(
          id: 'office-1',
          name: 'Office',
          readOnly: false,
          permissionKeys: [
            OfficePermissionKeys.clientsView,
            OfficePermissionKeys.clientMoney,
          ],
        ),
      );
      expect(
        officePermissionRedirectForScope(
          isPersonal: false,
          perms: perms,
          location: '/clients/c1/statement',
        ),
        isNull,
      );
    });

    test('redirects provider detail without providers view', () {
      final perms = OfficeAccountPermissions.office(
        const OfficeMembership(
          id: 'office-1',
          name: 'Office',
          readOnly: false,
          permissionKeys: [OfficePermissionKeys.clientsView],
        ),
      );
      expect(
        officePermissionRedirectForScope(
          isPersonal: false,
          perms: perms,
          location: '/providers/p1',
        ),
        '/home',
      );
    });
  });

  group('canOpenStatement', () {
    test('requires money and clients view', () {
      final viewOnly = OfficeAccountPermissions.office(
        const OfficeMembership(
          id: 'o',
          name: 'O',
          readOnly: false,
          permissionKeys: [OfficePermissionKeys.clientsView],
        ),
      );
      expect(canOpenStatement(viewOnly), isFalse);

      final ok = OfficeAccountPermissions.office(
        const OfficeMembership(
          id: 'o',
          name: 'O',
          readOnly: false,
          permissionKeys: [
            OfficePermissionKeys.clientsView,
            OfficePermissionKeys.clientMoney,
          ],
        ),
      );
      expect(canOpenStatement(ok), isTrue);
    });
  });
}