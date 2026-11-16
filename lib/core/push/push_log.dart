import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Debug-only console logs for FCM actions, under the `FCM` name.
abstract final class PushLog {
  static const _name = 'FCM';

  static void info(String message) {
    if (!kDebugMode) return;
    developer.log(message, name: _name);
  }

  static void error(String message, Object error, [StackTrace? stackTrace]) {
    if (!kDebugMode) return;
    developer.log(message, name: _name, level: 1000, error: error, stackTrace: stackTrace);
  }

  /// Shortens an installation ID so logs stay readable.
  static String id(String value) =>
      value.length <= 12 ? value : '${value.substring(0, 6)}…${value.substring(value.length - 6)}';

  static String message(RemoteMessage message) {
    final n = message.notification;
    return [
      'id=${message.messageId}',
      if (n?.title != null) 'title="${n!.title}"',
      if (n?.body != null) 'body="${n!.body}"',
      'data=${message.data}',
    ].join(' ');
  }
}
