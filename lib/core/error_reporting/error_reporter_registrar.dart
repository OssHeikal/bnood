import 'error_reporter.dart';
import 'sentry_config.dart';
import 'sentry_error_reporter.dart';

/// Registers error-reporting sinks enabled for this build.
List<ErrorReporter> buildErrorReporters({bool? sentryEnabled}) {
  final enabled = sentryEnabled ?? SentryConfig.isEnabled;
  if (!enabled) return const [];
  return const [SentryErrorReporter()];
}