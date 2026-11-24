import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app/bnood_root.dart';
import 'core/services/analytics/appsflyer/appsflyer_bootstrap.dart';
import 'core/services/analytics/domain/analytics_config.dart';
import 'core/services/analytics/domain/analytics_log.dart';
import 'core/services/analytics/firebase/firebase_analytics_bootstrap.dart';
import 'core/services/error_reporting/crashlytics_bootstrap.dart';
import 'core/services/error_reporting/sentry_bootstrap.dart';
import 'core/services/error_reporting/sentry_release_name.dart';
import 'core/data/prefs/app_settings_store.dart';
import 'core/network/push/push_background.dart';
import 'core/network/push/push_platform.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (pushMessagingSupported) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await bootstrapCrashlytics();
    await bootstrapFirebaseAnalytics();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  final packageInfo = await PackageInfo.fromPlatform();
  final release = sentryReleaseName(
    version: packageInfo.version,
    buildNumber: packageInfo.buildNumber,
  );
  await bootstrapSentry(release: release);

  final bootstrap = await AppSettingsStore.load();
  if (pushMessagingSupported) {
    await bootstrapAppsFlyer();
  }
  AnalyticsLog.info(
    'analytics compile-time enabled=${AnalyticsConfig.enabled} '
    'appsflyerKeySet=${AnalyticsConfig.appsFlyerDevKey.isNotEmpty} '
    'appsflyerSession=${AppsFlyerBootstrap.sessionStarted}',
  );
  runApp(BnoodRoot(bootstrap: bootstrap));
}
