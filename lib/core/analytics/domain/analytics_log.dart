import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'analytics_event.dart';
import 'analytics_user.dart';

/// Debug-only console logs for analytics, under the `Analytics` name.
abstract final class AnalyticsLog {
  static const _name = 'Analytics';

  static void info(String message) {
    if (!kDebugMode) return;
    developer.log(message, name: _name);
  }

  static void error(String message, Object error, [StackTrace? stackTrace]) {
    if (!kDebugMode) return;
    developer.log(message, name: _name, level: 1000, error: error, stackTrace: stackTrace);
  }

  static String event(AnalyticsEvent event) => '${event.name} ${event.params}';

  static String user(AnalyticsUser? user) {
    if (user == null) return 'cleared';
    return 'id=${user.id}';
  }
}
