import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app/bnood_app.dart';
import 'core/analytics/appsflyer/appsflyer_bootstrap.dart';
import 'core/analytics/domain/analytics_config.dart';
import 'core/analytics/domain/analytics_log.dart';
import 'core/analytics/firebase/firebase_analytics_bootstrap.dart';
import 'core/analytics/providers/analytics_providers.dart';
import 'core/error_reporting/error_reporting_providers.dart';
import 'core/error_reporting/install_error_handlers.dart';
import 'core/error_reporting/crashlytics_bootstrap.dart';
import 'core/error_reporting/sentry_bootstrap.dart';
import 'core/error_reporting/sentry_release_name.dart';
import 'core/prefs/app_settings_store.dart';
import 'core/app_state/settings_provider.dart';
import 'core/push/push_background.dart';
import 'core/push/push_platform.dart';
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
  final container = ProviderContainer(
    overrides: [appSettingsBootstrapProvider.overrideWithValue(bootstrap)],
  );
  if (pushMessagingSupported) {
    AppsFlyerBootstrap.onSessionStarted = () {
      container.invalidate(appsFlyerGatewayProvider);
      container.invalidate(analyticsSinksProvider);
      container.invalidate(analyticsServiceProvider);
    };
    await bootstrapAppsFlyer();
  }
  AnalyticsLog.info(
    'analytics compile-time enabled=${AnalyticsConfig.enabled} '
    'appsflyerKeySet=${AnalyticsConfig.appsFlyerDevKey.isNotEmpty} '
    'appsflyerSession=${AppsFlyerBootstrap.sessionStarted}',
  );
  installErrorHandlers(container.read(errorReporterProvider));
  runApp(
    UncontrolledProviderScope(container: container, child: const BnoodApp()),
  );
}
