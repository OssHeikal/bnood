import 'crashlytics_config.dart';
import 'crashlytics_error_reporter.dart';
import 'error_reporter.dart';
import 'sentry_config.dart';
import 'sentry_error_reporter.dart';

/// Registers error-reporting sinks enabled for this build.
List<ErrorReporter> buildErrorReporters({
  bool? sentryEnabled,
  bool? crashlyticsEnabled,
}) {
  final reporters = <ErrorReporter>[];
  if (sentryEnabled ?? SentryConfig.isEnabled) {
    reporters.add(const SentryErrorReporter());
  }
  if (crashlyticsEnabled ?? CrashlyticsConfig.isSupported) {
    reporters.add(CrashlyticsErrorReporter());
  }
  return List<ErrorReporter>.unmodifiable(reporters);
}