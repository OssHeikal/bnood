import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// FCM is supported only on Android and iOS (not web/desktop test hosts).
bool get pushMessagingSupported {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

String pushDevicePlatformValue() {
  if (kIsWeb) return 'web';
  if (Platform.isIOS) return 'ios';
  if (Platform.isAndroid) return 'android';
  return defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
}
