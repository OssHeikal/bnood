import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_provider.dart';

/// Disk prefs from [main]'s bootstrap override; null in partial test [ProviderScope]s.
SharedPreferences? tryReadBootstrapPrefs(Ref ref) {
  try {
    return ref.read(appSettingsBootstrapProvider).prefs;
  } on StateError {
    return null;
  }
}