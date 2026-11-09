import 'package:bnood/l10n/app_localizations.dart';

import '../../core/api/auth_api_exception.dart';

String authApiMessage(AppLocalizations l10n, AuthApiException error) {
  if (error.isNetwork) return l10n.authNetworkError;
  if (error.isThrottled) return l10n.authThrottled;
  if (error.isAccountExists) return l10n.authAccountExistsMessage;
  if (error.isInvalidCredentials) return l10n.authInvalidCredentials;
  if (error.isChallengeInvalid) return l10n.authChallengeInvalid;
  if (error.isSessionExpired) return l10n.authSessionExpired;
  if (error.isProfileIncomplete) return l10n.authCompleteProfileTitle;
  final fieldErrors = error.fieldErrors;
  if (fieldErrors != null) {
    for (final list in fieldErrors.values) {
      if (list.isNotEmpty) return list.first;
    }
  }
  return error.message;
}

String? fieldErrorFor(AuthApiException error, String field) {
  final list = error.fieldErrors?[field];
  if (list == null || list.isEmpty) return null;
  return list.first;
}
