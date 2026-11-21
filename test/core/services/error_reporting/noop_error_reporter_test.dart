import 'package:bnood/core/services/error_reporting/noop_error_reporter.dart';
import 'package:bnood/core/services/error_reporting/error_reporting_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts all calls without throwing', () {
    const reporter = NoopErrorReporter();

    expect(
      () => reporter.captureException(
        Exception('e'),
        StackTrace.empty,
        fatal: true,
      ),
      returnsNormally,
    );
    expect(() => reporter.captureMessage('msg'), returnsNormally);
    expect(() => reporter.addBreadcrumb(message: 'crumb'), returnsNormally);
    expect(
      () => reporter.setUser(const ErrorReportingUser(id: '1', phone: '010')),
      returnsNormally,
    );
    expect(() => reporter.clearUser(), returnsNormally);
  });
}
