import 'package:bnood/l10n/app_localizations.dart';

import '../../core/api/api_error_user_message.dart';
import '../../core/api/api_field_errors.dart';
import '../../core/api/auth_api_exception.dart';

String authApiMessage(AppLocalizations l10n, AuthApiException error) {
  if (error.isAccountExists) return l10n.authAccountExistsMessage;
  if (error.isInvalidCredentials) return l10n.authInvalidCredentials;
  if (error.isChallengeInvalid) return l10n.authChallengeInvalid;
  if (error.isProfileIncomplete) return l10n.authCompleteProfileTitle;
  if (error.isAccountDeleted) return l10n.authAccountDeletedMessage;
  return apiAuthErrorUserMessage(l10n, error);
}

String? fieldErrorFor(AuthApiException error, String field) {
  return ApiFieldErrorLookup(error).textFor(field);
}
