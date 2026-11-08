import 'package:bnood/l10n/app_localizations.dart';

import '../../core/api/subscriber_api_exception.dart';

String subscriberAuthMessage(AppLocalizations l10n, SubscriberApiException error) {
  if (error.isNetwork) return l10n.authNetworkError;
  if (error.isThrottled) return l10n.authThrottled;
  if (error.isInvalidCredentials) return l10n.authInvalidCredentials;
  if (error.isChallengeInvalid) return l10n.authChallengeInvalid;
  if (error.isSessionExpired) return l10n.authSessionExpired;
  final fieldErrors = error.fieldErrors;
  if (fieldErrors != null) {
    for (final list in fieldErrors.values) {
      if (list.isNotEmpty) return list.first;
    }
  }
  return error.message;
}

String? fieldErrorFor(SubscriberApiException error, String field) {
  final list = error.fieldErrors?[field];
  if (list == null || list.isEmpty) return null;
  return list.first;
}
