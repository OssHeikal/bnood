import 'package:bnood/l10n/app_localizations.dart';

String? validateEgyptPhone(AppLocalizations l10n, String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return l10n.authFieldRequired;
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 11 || !digits.startsWith('01')) {
    return l10n.authPhoneInvalid;
  }
  return null;
}

String? validateRequired(AppLocalizations l10n, String? value) {
  if (value == null || value.trim().isEmpty) return l10n.authFieldRequired;
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
  if (code.length < 4 || code.length > 8) return l10n.authCodeLengthHint;
  return null;
}
