import 'package:bnood/core/error_reporting/error_reporting_user.dart';
import 'package:bnood/core/error_reporting/reporting_user_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reportingUserIdentity extracts id and login phone', () {
    const input = ErrorReportingUser(id: '42', phone: '010', name: 'ignored');
    expect(
      reportingUserIdentity(input),
      const ReportingUserIdentity(id: '42', loginPhone: '010'),
    );
  });

  test('reportingUserIdentity is null for null input', () {
    expect(reportingUserIdentity(null), isNull);
  });
}