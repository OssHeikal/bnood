import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_controller.dart';
import '../../features/auth/auth_state.dart';
import 'user_session_reset.dart';

String? _sessionIdentity(AuthState? state) {
  if (state == null || !state.isAuthenticated) return null;
  return state.user?.id;
}

/// Watches auth transitions (login, logout, 401 bootstrap, account delete) and resets caches.
final userSessionLifecycleProvider = Provider<void>((ref) {
  ref.listen<AuthState>(authControllerProvider, (previous, next) {
    if (_sessionIdentity(previous) != _sessionIdentity(next)) {
      resetUserScopedState(ref);
    }
  });
});
