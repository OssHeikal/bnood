import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_controller.dart';
import '../../features/auth/auth_state.dart';
import 'error_reporting_providers.dart';
import 'error_reporting_user.dart';

ErrorReportingUser? _userFromAuth(AuthState auth) {
  if (!auth.isAuthenticated) return null;
  final user = auth.user;
  if (user == null) return null;
  return ErrorReportingUser(
    id: user.id,
    phone: user.phone,
    name: user.name,
  );
}

bool _sameReportingUser(ErrorReportingUser? a, ErrorReportingUser? b) => a == b;

/// Mirrors login session into [ErrorReporter] user context.
final errorReportingLifecycleProvider = Provider<void>((ref) {
  final reporter = ref.watch(errorReporterProvider);

  void sync(AuthState auth) {
    final user = _userFromAuth(auth);
    if (user == null) {
      reporter.clearUser();
    } else {
      reporter.setUser(user);
    }
  }

  sync(ref.read(authControllerProvider));

  ref.listen<AuthState>(authControllerProvider, (previous, next) {
    final prevUser = previous == null ? null : _userFromAuth(previous);
    final nextUser = _userFromAuth(next);
    if (_sameReportingUser(prevUser, nextUser)) return;
    sync(next);
  });
});