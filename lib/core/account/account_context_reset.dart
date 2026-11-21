import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/session/user_session_reset.dart';

/// Test-only hook to assert account switches invalidate user-scoped caches.
void Function()? debugAccountScopedResetHook;

/// Drops Riverpod and in-memory HTTP caches after the active account changes.
void resetAccountScopedState(Ref ref) {
  debugAccountScopedResetHook?.call();
  resetUserScopedState(ref);
}

/// Same as [resetAccountScopedState] for tests using a [ProviderContainer].
void resetAccountScopedStateFromContainer(ProviderContainer container) {
  debugAccountScopedResetHook?.call();
  resetUserScopedStateFromContainer(container);
}