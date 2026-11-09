import '../../core/api/auth_api_exception.dart';

/// Controller-level login result for UI routing (session, silent OTP, or error).
sealed class LoginOutcome {
  const LoginOutcome();
}

final class LoginOutcomeAuthenticated extends LoginOutcome {
  const LoginOutcomeAuthenticated();
}

final class LoginOutcomeRegistrationChallenge extends LoginOutcome {
  const LoginOutcomeRegistrationChallenge();
}

final class LoginOutcomeFailed extends LoginOutcome {
  const LoginOutcomeFailed(this.error);

  final AuthApiException error;
}
