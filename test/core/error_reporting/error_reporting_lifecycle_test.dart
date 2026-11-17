import 'package:bnood/core/error_reporting/error_reporting_lifecycle.dart';
import 'package:bnood/core/error_reporting/error_reporting_providers.dart';
import 'package:bnood/core/error_reporting/error_reporting_user.dart';
import 'package:bnood/core/error_reporting/error_reporter.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class LifecycleRecorder implements ErrorReporter {
  ErrorReportingUser? user;
  int clearUserCount = 0;

  @override
  void addBreadcrumb({required String message, String? category, Map<String, Object?>? data}) {}

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
  void clearUser() {
    clearUserCount++;
    user = null;
  }

  @override
  void setUser(ErrorReportingUser? value) => user = value;
}

class _AuthStub extends AuthController {
  @override
  AuthState build() => const AuthState();
}

void main() {
  test('errorReportingLifecycleProvider sets user on login and clears on logout', () {
    final recorder = LifecycleRecorder();
    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(_AuthStub.new),
        errorReportersProvider.overrideWithValue([recorder]),
      ],
    );
    addTearDown(container.dispose);

    container.read(errorReportingLifecycleProvider);

    const authUser = User(id: '42', phone: '01098765432', name: 'Site Lead');
    container.read(authControllerProvider.notifier).state = const AuthState(
      bootstrapStatus: AuthBootstrapStatus.authenticated,
      user: authUser,
    );

    expect(
      recorder.user,
      const ErrorReportingUser(id: '42', phone: '01098765432', name: 'Site Lead'),
    );

    container.read(authControllerProvider.notifier).state =
        container.read(authControllerProvider).copyWith(
              bootstrapStatus: AuthBootstrapStatus.unauthenticated,
              clearUser: true,
            );

    expect(recorder.clearUserCount, greaterThanOrEqualTo(1));
    expect(recorder.user, isNull);
  });
}