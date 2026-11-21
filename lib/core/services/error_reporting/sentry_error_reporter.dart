import 'package:sentry_flutter/sentry_flutter.dart';

import 'error_reporter.dart';
import 'error_reporting_user.dart';
import 'sentry_user_mapping.dart';

final class SentryErrorReporter implements ErrorReporter {
  const SentryErrorReporter();

  @override
  void addBreadcrumb({
    required String message,
    String? category,
    Map<String, Object?>? data,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        data: data?.map((key, value) => MapEntry(key, value)),
        level: SentryLevel.info,
      ),
    );
  }

  @override
  void captureException(
    Object error,
    StackTrace? stackTrace, {
    Map<String, Object?>? context,
    bool fatal = false,
  }) {
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.level = fatal ? SentryLevel.fatal : SentryLevel.error;
        _attachContext(scope, context);
      },
    );
  }

  @override
  void captureMessage(
    String message, {
    Map<String, Object?>? context,
    ErrorReportLevel level = ErrorReportLevel.info,
  }) {
    Sentry.captureMessage(
      message,
      level: _sentryLevel(level),
      withScope: (scope) {
        _attachContext(scope, context);
      },
    );
  }

  @override
  void clearUser() {
    Sentry.configureScope((scope) => scope.setUser(null));
  }

  @override
  void setUser(ErrorReportingUser? user) {
    final sentryUser = sentryUserForReporting(user);
    Sentry.configureScope((scope) => scope.setUser(sentryUser));
  }

  static void _attachContext(Scope scope, Map<String, Object?>? context) {
    if (context == null || context.isEmpty) return;
    scope.setContexts('error_reporting', Map<String, dynamic>.from(context));
  }

  static SentryLevel _sentryLevel(ErrorReportLevel level) {
    return switch (level) {
      ErrorReportLevel.debug => SentryLevel.debug,
      ErrorReportLevel.info => SentryLevel.info,
      ErrorReportLevel.warning => SentryLevel.warning,
      ErrorReportLevel.error => SentryLevel.error,
      ErrorReportLevel.fatal => SentryLevel.fatal,
    };
  }
}
