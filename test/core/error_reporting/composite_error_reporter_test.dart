import 'package:bnood/core/error_reporting/composite_error_reporter.dart';
import 'package:bnood/core/error_reporting/error_reporter.dart';
import 'package:bnood/core/error_reporting/error_reporting_user.dart';
import 'package:flutter_test/flutter_test.dart';

class RecordingErrorReporter implements ErrorReporter {
  final List<Object> exceptions = [];
  final List<String> messages = [];
  ErrorReportingUser? user;
  int clearUserCount = 0;
  final List<String> breadcrumbs = [];
  bool throwOnNext = false;

  @override
  void addBreadcrumb({
    required String message,
    String? category,
    Map<String, Object?>? data,
  }) {
    if (throwOnNext) throw StateError('breadcrumb failed');
    breadcrumbs.add(message);
  }

  @override
  void captureException(
    Object error,
    StackTrace? stackTrace, {
    Map<String, Object?>? context,
    bool fatal = false,
  }) {
    if (throwOnNext) throw StateError('captureException failed');
    exceptions.add(error);
  }

  @override
  void captureMessage(
    String message, {
    Map<String, Object?>? context,
    ErrorReportLevel level = ErrorReportLevel.info,
  }) {
    if (throwOnNext) throw StateError('captureMessage failed');
    messages.add(message);
  }

  @override
  void clearUser() {
    if (throwOnNext) throw StateError('clearUser failed');
    clearUserCount++;
    user = null;
  }

  @override
  void setUser(ErrorReportingUser? value) {
    if (throwOnNext) throw StateError('setUser failed');
    user = value;
  }
}

void main() {
  test('fans out capture calls to every reporter', () {
    final a = RecordingErrorReporter();
    final b = RecordingErrorReporter();
    final composite = CompositeErrorReporter([a, b]);

    composite.captureException(Exception('x'), StackTrace.current, fatal: true);
    composite.captureMessage('hello');
    composite.addBreadcrumb(message: 'nav');

    expect(a.exceptions, hasLength(1));
    expect(b.exceptions, hasLength(1));
    expect(a.messages, ['hello']);
    expect(b.messages, ['hello']);
    expect(a.breadcrumbs, ['nav']);
    expect(b.breadcrumbs, ['nav']);
  });

  test('isolates a failing reporter', () {
    final failing = RecordingErrorReporter()..throwOnNext = true;
    final ok = RecordingErrorReporter();
    final composite = CompositeErrorReporter([failing, ok]);

    expect(
      () => composite.captureException(Exception('e'), null),
      returnsNormally,
    );
    expect(ok.exceptions, hasLength(1));
    expect(failing.exceptions, isEmpty);

    failing.throwOnNext = false;
    ok.exceptions.clear();

    expect(
      () => composite.setUser(const ErrorReportingUser(id: '1', phone: '010')),
      returnsNormally,
    );
    expect(ok.user?.id, '1');
  });

  test('setUser and clearUser fan out', () {
    final a = RecordingErrorReporter();
    final b = RecordingErrorReporter();
    final composite = CompositeErrorReporter([a, b]);
    const user = ErrorReportingUser(
      id: 'u1',
      phone: '01012345678',
      name: 'Engineer',
    );

    composite.setUser(user);
    expect(a.user, user);
    expect(b.user, user);

    composite.clearUser();
    expect(a.clearUserCount, 1);
    expect(b.clearUserCount, 1);
    expect(a.user, isNull);
    expect(b.user, isNull);
  });
}
