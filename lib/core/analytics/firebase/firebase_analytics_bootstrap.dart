import 'package:firebase_analytics/firebase_analytics.dart';

import '../../push/push_platform.dart';
import '../domain/analytics_config.dart';
import '../domain/analytics_log.dart';

/// Applies compile-time [AnalyticsConfig.enabled] to the native Firebase Analytics SDK.
Future<void> bootstrapFirebaseAnalytics() async {
  if (!pushMessagingSupported) {
    AnalyticsLog.info('firebase skipped: unsupported platform');
    return;
  }

  final enabled = AnalyticsConfig.enabled;
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enabled);
  AnalyticsLog.info('firebase collection ${enabled ? 'on' : 'off'}');
}
