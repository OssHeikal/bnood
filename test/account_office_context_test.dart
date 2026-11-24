import 'package:bnood/core/account/account_office_mutations.dart';
import 'package:bnood/core/account/auth_office_payload.dart';
import 'package:bnood/core/account/office_membership.dart';
import 'package:bnood/core/network/api/auth_api_exception.dart';
import 'package:bnood/core/network/api/auth_me_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AuthMePayload parses data.office and nested offices', () {
    final payload = AuthMePayload.fromData({
      'user': {'id': 'u1', 'phone': '01000000000', 'name': 'أسامة'},
      'office': {
        'open_dashboard': true,
        'dashboard_url': 'https://office.bnood.test',
        'offices': [
          {
            'id': '01J9Z8XQ8K9M2N3P4R5S6T7V8W',
            'name': 'مكتب النور',
            'read_only': true,
            'status': 'active',
            'dashboard_url': 'https://office.bnood.test/o/1',
            'role': {'is_owner': true, 'name_ar': 'مالك'},
          },
        ],
      },
    });

    expect(payload.office?.hasOffices, isTrue);
    expect(payload.office?.openDashboard, isTrue);
    expect(payload.office!.offices.single.isReadOnly, isTrue);
    expect(payload.office!.offices.single.isOwner, isTrue);
    expect(payload.office!.offices.single.name, 'مكتب النور');
  });

  test('accountOfficeMutationsEnabled respects personal vs read-only office', () {
    const office = OfficeMembership(
      id: 'o1',
      name: 'Office',
      readOnly: true,
    );

    expect(
      accountOfficeMutationsEnabled(isPersonal: true, selectedOffice: office),
      isTrue,
    );
    expect(
      accountOfficeMutationsEnabled(isPersonal: false, selectedOffice: office),
      isFalse,
    );
    expect(
      accountOfficeMutationsEnabled(
        isPersonal: false,
        selectedOffice: const OfficeMembership(
          id: 'o2',
          name: 'Active',
          readOnly: false,
        ),
      ),
      isTrue,
    );
  });

  test('office_read_only maps to server Arabic displayMessage', () {
    const message = 'المكتب في وضع القراءة فقط';
    final error = AuthApiException(
      statusCode: 403,
      message: message,
      code: 'office_read_only',
    );
    expect(error.isOfficeReadOnly, isTrue);
    expect(error.displayMessage, message);
  });

  test('membership list reconcile helper', () {
    const id = '01J9Z8XQ8K9M2N3P4R5S6T7V8W';
    const offices = [
      OfficeMembership(id: id, name: 'A', readOnly: false),
    ];
    expect(officeMembershipListContains(offices, id), isTrue);
    expect(officeMembershipListContains(offices, 'other'), isFalse);
  });

  test('AuthOfficePayload tolerates missing office block', () {
    expect(AuthOfficePayload.fromJson(null).offices, isEmpty);
  });

  test('accountOfficeMutationsEnabled view-only when permission_keys omit manage', () {
    const viewOnly = OfficeMembership(
      id: 'o-view',
      name: 'View',
      readOnly: false,
      permissionKeys: ['clients_view', 'web_access'],
    );
    expect(
      accountOfficeMutationsEnabled(isPersonal: false, selectedOffice: viewOnly),
      isFalse,
    );

    const manager = OfficeMembership(
      id: 'o-mgr',
      name: 'Mgr',
      readOnly: false,
      permissionKeys: ['clients_manage', 'web_access'],
    );
    expect(
      accountOfficeMutationsEnabled(isPersonal: false, selectedOffice: manager),
      isTrue,
    );
  });
}