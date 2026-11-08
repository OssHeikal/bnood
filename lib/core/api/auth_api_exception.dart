class AuthApiException implements Exception {
  AuthApiException({
    required this.statusCode,
    required this.message,
    this.code,
    this.fieldErrors,
  });

  final int statusCode;
  final String message;
  final String? code;
  final Map<String, List<String>>? fieldErrors;

  bool get isInvalidCredentials => code == 'invalid_credentials';
  bool get isChallengeInvalid => code == 'challenge_invalid';
  bool get isThrottled => statusCode == 429 || code == 'throttled';
  bool get isUnauthorized => statusCode == 401;

  bool get isNetwork => statusCode == 0 || code == 'network';

  bool get isSessionExpired =>
      isUnauthorized && !isInvalidCredentials && code != 'invalid_credentials';
}
