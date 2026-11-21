import 'package:shared_preferences/shared_preferences.dart';

import 'account_scope.dart';

/// Persists last selected account (personal or office id) in preferences.
abstract final class AccountContextStore {
  static const valuePersonal = 'personal';
  static const _selectionKey = 'bnood.account.selection';

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

  static Future<AccountScope> readScope(SharedPreferences? prefs) async {
    if (prefs == null) return const AccountScope.personal();
    return scopeFromStored(prefs.getString(_selectionKey));
  }

  static Future<void> writeScope(
    SharedPreferences? prefs,
    AccountScope scope,
  ) async {
    if (prefs == null) return;
    await prefs.setString(_selectionKey, encodeScope(scope));
  }

  /// Crockford base32 ULID (26 chars). Loose check for local restore until M2 validates membership.
  static bool isPlausibleOfficeId(String value) {
    if (value.length != 26) return false;
    return RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$').hasMatch(value);
  }
}