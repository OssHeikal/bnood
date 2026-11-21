import 'error_reporter.dart';
import 'error_reporting_user.dart';

final class NoopErrorReporter implements ErrorReporter {
  const NoopErrorReporter();

  static const NoopErrorReporter instance = NoopErrorReporter();

  @override
  void addBreadcrumb({
    required String message,
    String? category,
    Map<String, Object?>? data,
  }) {}

  @override
  void captureException(
    Object error,
    StackTrace? stackTrace, {
    Map<String, Object?>? context,
    bool fatal = false,
  }) {}

  @override
  void captureMessage(
    String message, {
    Map<String, Object?>? context,
    ErrorReportLevel level = ErrorReportLevel.info,
  }) {}

  @override
  void clearUser() {}

  @override
  void setUser(ErrorReportingUser? user) {}
}
