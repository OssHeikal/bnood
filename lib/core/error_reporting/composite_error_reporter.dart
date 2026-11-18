import 'error_reporter.dart';
import 'error_reporting_user.dart';

/// Fans out to every configured reporter; one failing sink never affects the rest.
final class CompositeErrorReporter implements ErrorReporter {
  CompositeErrorReporter(Iterable<ErrorReporter> reporters)
      : _reporters = List<ErrorReporter>.unmodifiable(reporters);

  final List<ErrorReporter> _reporters;

  @override
  void addBreadcrumb({required String message, String? category, Map<String, Object?>? data}) {
    _forEach((reporter) => reporter.addBreadcrumb(
          message: message,
          category: category,
          data: data,
        ));
  }

  @override
  void captureException(
    Object error,
    StackTrace? stackTrace, {
    Map<String, Object?>? context,
    bool fatal = false,
  }) {
    _forEach((reporter) => reporter.captureException(
          error,
          stackTrace,
          context: context,
          fatal: fatal,
        ));
  }

  @override
  void captureMessage(
    String message, {
    Map<String, Object?>? context,
    ErrorReportLevel level = ErrorReportLevel.info,
  }) {
    _forEach((reporter) => reporter.captureMessage(
          message,
          context: context,
          level: level,
        ));
  }

  @override
  void clearUser() {
    _forEach((reporter) => reporter.clearUser());
  }

  @override
  void setUser(ErrorReportingUser? user) {
    _forEach((reporter) => reporter.setUser(user));
  }

  void _forEach(void Function(ErrorReporter reporter) action) {
    for (final reporter in _reporters) {
      try {
        action(reporter);
      } on Object {
        // Isolate failing sinks so telemetry never breaks the app.
      }
    }
  }
}