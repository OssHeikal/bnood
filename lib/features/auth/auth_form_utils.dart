import 'package:bnood/l10n/app_localizations.dart';

import '../../core/validation/egypt_mobile_phone_validation.dart';

String? validateEgyptPhone(AppLocalizations l10n, String? raw) =>
    validateRequiredEgyptMobile(l10n, raw);

String? validateRequired(AppLocalizations l10n, String? value) {
  if (value == null || value.trim().isEmpty) return l10n.authFieldRequired;
  return null;
}

const _displayNameMaxLength = 120;

String? validateDisplayName(AppLocalizations l10n, String? value) {
  final required = validateRequired(l10n, value);
  if (required != null) return required;
  if (value!.trim().length > _displayNameMaxLength) {
    return l10n.authDisplayNameTooLong;
  }
  return null;
}

String? validatePassword(AppLocalizations l10n, String? value) {
  final v = value ?? '';
  if (v.isEmpty) return l10n.authFieldRequired;
  if (v.length < 8) return l10n.authPasswordMinLength;
  return null;
}

String? validatePasswordConfirmation(
  AppLocalizations l10n,
  String? value,
  String password,
) {
  final mismatch = validateRequired(l10n, value);
  if (mismatch != null) return mismatch;
  if (value != password) return l10n.authPasswordMismatch;
  return null;
}

String? validateVerificationCode(AppLocalizations l10n, String? value) {
  final code = value?.trim() ?? '';
  if (code.isEmpty) return l10n.authFieldRequired;
  if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
    return l10n.authCodeLengthHint;
  }
  return null;
}
