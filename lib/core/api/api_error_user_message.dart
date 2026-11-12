import 'package:bnood/l10n/app_localizations.dart';

import 'auth_api_exception.dart';

/// User-facing toast copy for API and unexpected failures (never raw [Object.toString]).
String apiErrorUserMessage(AppLocalizations l10n, Object error) {
  if (error is AuthApiException) {
    return apiAuthErrorUserMessage(l10n, error);
  }
  return l10n.apiGenericFailure;
}

/// Shared API failure copy (validation uses server field text via [Accept-Language]).
String apiAuthErrorUserMessage(AppLocalizations l10n, AuthApiException error) {
  if (error.isNetwork) return l10n.apiErrorNetwork;
  if (error.isThrottled) return l10n.apiErrorThrottled;
  if (error.isSessionExpired ||
      (error.isUnauthorized && !error.isInvalidCredentials && error.code != 'invalid_credentials')) {
    return l10n.apiErrorSessionExpired;
  }
  if (error.isInvalidSize || error.statusCode == 413) {
    return l10n.apiErrorPayloadTooLarge;
  }
  if (error.statusCode >= 500) return l10n.apiErrorServer;
  final fields = error.fieldErrors;
  if (fields != null && fields.isNotEmpty) return error.displayMessage;
  return error.displayMessage;
}
