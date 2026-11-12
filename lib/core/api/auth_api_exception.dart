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

  bool get isAccountDeleted => code == 'account_deleted';

  bool get isActiveProjectCapReached => statusCode == 403 && code == 'active_project_cap_reached';

  bool get isSubscriptionFinancialReadOnly =>
      statusCode == 403 && code == 'subscription_financial_read_only';
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

  bool get isClientArchivedAgreement =>
      statusCode == 422 && code == 'client_archived';

  bool get isProviderNotCraftsman =>
      statusCode == 422 && code == 'provider_not_craftsman';

  bool get isAlreadyLinked => statusCode == 422 && code == 'already_linked';

  bool get isClientNotFound => statusCode == 404 && code == 'client_not_found';

  bool get isProviderNotFound => statusCode == 404 && code == 'provider_not_found';

  bool get isItemNotFound => statusCode == 404 && code == 'item_not_found';

  bool get isVoucherNotFound => statusCode == 404 && code == 'not_found';

  bool get isClientArchivedVoucher => statusCode == 422 && code == 'client_archived';

  bool get isInvalidReceiveFields => statusCode == 422 && code == 'invalid_receive_fields';

  bool get isSpendRequiresItem => statusCode == 422 && code == 'spend_requires_item';

  bool get isSpendRequiresExpenseClassification =>
      statusCode == 422 && code == 'spend_requires_expense_classification';

  bool get isLaborRequiresCraftsman => statusCode == 422 && code == 'labor_requires_craftsman';

  bool get isProviderTypeMismatch => statusCode == 422 && code == 'provider_type_mismatch';

  bool get isInvalidAmount => statusCode == 422 && code == 'invalid_amount';

  bool get isInvalidMime => statusCode == 422 && code == 'invalid_mime';

  bool get isInvalidSize =>
      statusCode == 413 || (statusCode == 422 && code == 'invalid_size');

  bool get isStorageFailed => statusCode == 500 && code == 'storage_failed';

  /// Best user-facing detail from the API body (field messages before top-level [message]).
  ///
  /// Network localization belongs in [apiErrorUserMessage] — this getter keeps the transport copy.
  String get displayMessage {
    final errors = fieldErrors;
    if (errors != null && errors.isNotEmpty) {
      final seen = <String>{};
      final parts = <String>[];
      for (final list in errors.values) {
        for (final raw in list) {
          final text = raw.trim();
          if (text.isEmpty || !seen.add(text)) continue;
          parts.add(text);
          if (parts.length >= 3) break;
        }
        if (parts.length >= 3) break;
      }
      if (parts.isNotEmpty) return parts.join('\n');
    }
    return message;
  }

  @override
  String toString() => 'AuthApiException($statusCode, $code, $message)';
}
