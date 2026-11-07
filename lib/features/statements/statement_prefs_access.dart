import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Safe access to SharedPreferences for statement export cursors.
///
/// Returns null when the platform channel is unavailable (e.g. native plugin
/// not registered until a full rebuild). Does not fix registration — only
/// prevents unhandled async failures in Dart.
abstract final class StatementPrefsAccess {
  static Future<SharedPreferences?> getInstance() async {
    try {
      return await SharedPreferences.getInstance();
    } on PlatformException catch (e, st) {
      debugPrint('StatementPrefsAccess: platform prefs unavailable: $e');
      debugPrint('$st');
      return null;
    } catch (e, st) {
      debugPrint('StatementPrefsAccess: prefs unavailable: $e');
      debugPrint('$st');
      return null;
    }
  }
}
