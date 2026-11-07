import '../../core/prefs/bnood_prefs_access.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Statement export cursors reuse shared [BnoodPrefsAccess].
abstract final class StatementPrefsAccess {
  static Future<SharedPreferences?> getInstance() => BnoodPrefsAccess.getInstance();
}
