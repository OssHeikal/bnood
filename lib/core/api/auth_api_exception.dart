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

  bool get isAccountExists => code == 'account_exists';

  bool get isInvalidCredentials => code == 'invalid_credentials';
  bool get isChallengeInvalid => code == 'challenge_invalid';
  bool get isThrottled => statusCode == 429 || code == 'throttled';
  bool get isUnauthorized => statusCode == 401;

  bool get isNetwork => statusCode == 0 || code == 'network';

  bool get isSessionExpired =>
      isUnauthorized && !isInvalidCredentials && code != 'invalid_credentials';

  bool get isProfileIncomplete => statusCode == 403 && code == 'profile_incomplete';

  bool get isNotFound => statusCode == 404 && code == 'not_found';

  bool get isDuplicateName =>
      code == 'duplicate_name' && (statusCode == 409 || statusCode == 422);

  bool get isDefaultItemReadonly => statusCode == 403 && code == 'default_item_readonly';

  bool get isItemInUse => statusCode == 409 && code == 'item_in_use';

  bool get isDuplicatePhone => statusCode == 422 && code == 'duplicate_phone';

  bool get isClientArchived => statusCode == 409 && code == 'client_archived';

  bool get isClientHasActivity => statusCode == 409 && code == 'client_has_activity';
}
