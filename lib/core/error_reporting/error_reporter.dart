import 'error_reporting_user.dart';

/// Sink for crash and diagnostic events (implementation-specific backends plug in later).
abstract interface class ErrorReporter {
  void captureException(
    Object error,
    StackTrace? stackTrace, {
    Map<String, Object?>? context,
    bool fatal = false,
  });

  void captureMessage(
    String message, {
    Map<String, Object?>? context,
    ErrorReportLevel level = ErrorReportLevel.info,
  });

  void setUser(ErrorReportingUser? user);

  void clearUser();

  void addBreadcrumb({
    required String message,
    String? category,
    Map<String, Object?>? data,
  });
}

enum ErrorReportLevel { debug, info, warning, error, fatal }