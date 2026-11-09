import '../features/auth/auth_paths.dart';
import '../features/auth/auth_state.dart';

/// Where the splash should send the user once startup auth is resolved.
String appSplashDestinationFor(AuthState auth) {
  switch (auth.bootstrapStatus) {
    case AuthBootstrapStatus.authenticated:
      final user = auth.user;
      if (user != null) {
        return authenticatedHomeFor(user);
      }
      return AuthPaths.login;
    case AuthBootstrapStatus.bootstrapNetworkError:
      return AuthPaths.bootstrap;
    case AuthBootstrapStatus.unauthenticated:
      return AuthPaths.login;
    case AuthBootstrapStatus.bootstrapping:
    case AuthBootstrapStatus.idle:
      return AuthPaths.login;
  }
}

bool appSplashSessionResolved(AuthState auth) {
  if (!auth.bootstrapStarted) return false;
  return auth.bootstrapStatus != AuthBootstrapStatus.bootstrapping &&
      auth.bootstrapStatus != AuthBootstrapStatus.idle;
}
