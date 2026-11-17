import 'package:bnood/core/error_reporting/error_reporter_registrar.dart';
import 'package:bnood/core/error_reporting/sentry_error_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildErrorReporters returns empty when Sentry disabled', () {
    expect(buildErrorReporters(sentryEnabled: false), isEmpty);
  });

  test('buildErrorReporters includes SentryErrorReporter when enabled', () {
    final reporters = buildErrorReporters(sentryEnabled: true);
    expect(reporters, hasLength(1));
    expect(reporters.single, isA<SentryErrorReporter>());
  });
}