import 'package:shared_preferences/shared_preferences.dart';

import 'account_scope.dart';

/// Persists last selected account (personal or office id) in preferences.
abstract final class AccountContextStore {
  static const valuePersonal = 'personal';
  static const _selectionKey = 'bnood.account.selection';
  static const _previousKey = 'bnood.account.previous';

  static AccountScope scopeFromStored(String? raw) {
    if (raw == null || raw.isEmpty || raw == valuePersonal) {
      return const AccountScope.personal();
    }
    if (isPlausibleOfficeId(raw)) {
      return AccountScope.office(raw);
    }
    return const AccountScope.personal();
  }

  static String encodeScope(AccountScope scope) {
    return scope.isPersonal ? valuePersonal : scope.officeId!;
  }

  static AccountScope readScopeSync(SharedPreferences? prefs) {
    if (prefs == null) return const AccountScope.personal();
    return scopeFromStored(prefs.getString(_selectionKey));
  }

  static Future<AccountScope> readScope(SharedPreferences? prefs) async {
    return readScopeSync(prefs);
  }

  static Future<void> writeScope(
    SharedPreferences? prefs,
    AccountScope scope,
  ) async {
    if (prefs == null) return;
    await prefs.setString(_selectionKey, encodeScope(scope));
  }

  static Future<AccountScope?> readPreviousScope(SharedPreferences? prefs) async {
    if (prefs == null) return null;
    final raw = prefs.getString(_previousKey);
    if (raw == null || raw.isEmpty) return null;
    if (raw == valuePersonal) return const AccountScope.personal();
    if (isPlausibleOfficeId(raw)) return AccountScope.office(raw);
    return null;
  }

  static Future<void> writePreviousScope(
    SharedPreferences? prefs,
    AccountScope scope,
  ) async {
    if (prefs == null) return;
    await prefs.setString(_previousKey, encodeScope(scope));
  }

  /// Clears persisted scope and quick-switch memory on sign-out.
  static Future<void> clearPersisted(SharedPreferences? prefs) async {
    if (prefs == null) return;
    await prefs.remove(_selectionKey);
    await prefs.remove(_previousKey);
  }

  /// Crockford base32 ULID (26 chars). Case-insensitive: the API sends lowercase.
  /// Loose check for local restore until membership is validated.
  static bool isPlausibleOfficeId(String value) {
    if (value.length != 26) return false;
    return RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$').hasMatch(value.toUpperCase());
  }
}