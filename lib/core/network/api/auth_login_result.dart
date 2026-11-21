import 'auth_api.dart';

/// POST /auth/login response: 200 session vs 202 registration challenge (no token).
sealed class LoginResult {
  const LoginResult();
}

final class LoginResultSession extends LoginResult {
  const LoginResultSession(this.session);

  final AuthSessionPayload session;
}

final class LoginRegistrationChallenge extends LoginResult {
  const LoginRegistrationChallenge(this.challenge);

  final RegistrationAccepted challenge;
}
