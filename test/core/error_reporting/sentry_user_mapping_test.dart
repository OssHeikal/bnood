import 'package:bnood/core/error_reporting/error_reporting_user.dart';
import 'package:bnood/core/error_reporting/sentry_user_mapping.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sentryUserForReporting maps id and login phone only', () {
    const input = ErrorReportingUser(
      id: 'usr-1',
      phone: '01012345678',
      name: 'Engineer Name',
    );

    final sentryUser = sentryUserForReporting(input);
    expect(sentryUser, isNotNull);
    expect(sentryUser!.id, 'usr-1');
    expect(sentryUser.username, '01012345678');
    expect(sentryUser.name, isNull);
    expect(sentryUser.email, isNull);
  });

  test('sentryUserForReporting is null when input is null', () {
    expect(sentryUserForReporting(null), isNull);
  });
}
