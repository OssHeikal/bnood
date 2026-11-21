import 'package:bnood/core/error_reporting/crashlytics_error_reporter.dart';
import 'package:bnood/core/error_reporting/error_reporter_registrar.dart';
import 'package:bnood/core/error_reporting/sentry_error_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildErrorReporters returns empty when all backends disabled', () {
    expect(
      buildErrorReporters(sentryEnabled: false, crashlyticsEnabled: false),
      isEmpty,
    );
  });

  test('buildErrorReporters includes SentryErrorReporter when enabled', () {
    final reporters = buildErrorReporters(
      sentryEnabled: true,
      crashlyticsEnabled: false,
    );
    expect(reporters, hasLength(1));
    expect(reporters.single, isA<SentryErrorReporter>());
  });

  test(
    'buildErrorReporters includes CrashlyticsErrorReporter when enabled',
    () {
      final reporters = buildErrorReporters(
        sentryEnabled: false,
        crashlyticsEnabled: true,
      );
      expect(reporters, hasLength(1));
      expect(reporters.single, isA<CrashlyticsErrorReporter>());
    },
  );

  test('buildErrorReporters registers Sentry and Crashlytics together', () {
    final reporters = buildErrorReporters(
      sentryEnabled: true,
      crashlyticsEnabled: true,
    );
    expect(reporters, hasLength(2));
    expect(reporters.whereType<SentryErrorReporter>(), hasLength(1));
    expect(reporters.whereType<CrashlyticsErrorReporter>(), hasLength(1));
  });
}
