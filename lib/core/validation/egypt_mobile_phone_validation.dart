import 'package:bnood/l10n/app_localizations.dart';

import 'egypt_mobile_phone.dart';

String? validateOptionalEgyptMobile(AppLocalizations l10n, String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return null;
  if (!EgyptMobilePhone.isValid(value)) return l10n.egyptMobileInvalid;
  return null;
}

String? validateRequiredEgyptMobile(AppLocalizations l10n, String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return l10n.authFieldRequired;
  return validateOptionalEgyptMobile(l10n, value);
}

/// Optional phone for API payloads: null when empty, else normalized 11 digits.
String? egyptMobileForApi(String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return null;
  return EgyptMobilePhone.normalizeDigits(value);
}
