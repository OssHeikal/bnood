import 'package:shared_preferences/shared_preferences.dart';

const _pushPermissionPromptedKey = 'push_os_permission_prompted_v1';

class PushPermissionStore {
  Future<bool> wasOsPermissionPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pushPermissionPromptedKey) ?? false;
  }

  Future<void> markOsPermissionPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushPermissionPromptedKey, true);
  }
}
