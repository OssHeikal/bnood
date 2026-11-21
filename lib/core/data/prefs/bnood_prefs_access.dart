import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Safe SharedPreferences access for app settings and other local cursors.
///
/// Returns null when the platform channel is unavailable (native plugin not
/// registered until a full rebuild).
abstract final class BnoodPrefsAccess {
  static Future<SharedPreferences?> getInstance() async {
    try {
      return await SharedPreferences.getInstance();
    } on PlatformException catch (e, st) {
      debugPrint('BnoodPrefsAccess: platform prefs unavailable: $e');
      debugPrint('$st');
      return null;
    } catch (e, st) {
      debugPrint('BnoodPrefsAccess: prefs unavailable: $e');
      debugPrint('$st');
      return null;
    }
  }
}
