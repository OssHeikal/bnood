import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

import '../../push/push_platform.dart';
import '../domain/analytics_config.dart';
import '../domain/analytics_log.dart';

abstract final class AppsFlyerBootstrap {
  static bool ready = false;
}

/// Initializes AppsFlyer on mobile when [AnalyticsConfig.appsFlyerDevKey] is set.
///
/// On iOS, requests ATT when still undetermined, then starts the first session.
Future<void> bootstrapAppsFlyer() async {
  AppsFlyerBootstrap.ready = false;
  if (!pushMessagingSupported) {
    AnalyticsLog.info('appsflyer skipped: unsupported platform');
    return;
  }

  final devKey = AnalyticsConfig.appsFlyerDevKey;
  if (devKey.isEmpty) {
    AnalyticsLog.info('appsflyer skipped: APPSFLYER_DEV_KEY empty');
    return;
  }

  try {
    final sdk = AppsFlyerSdk.instance;
    final iosAppId = AnalyticsConfig.appsFlyerIosAppId;
    await sdk.init(devKey: devKey, appId: Platform.isIOS ? iosAppId : null);

    var attHandled = false;
    await sdk.registerSessionReadyListener(() async {
      if (!attHandled && Platform.isIOS) {
        final status = await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
        attHandled = true;
      }
      try {
        await sdk.start();
        AnalyticsLog.info('appsflyer session started');
      } catch (error, stackTrace) {
        AnalyticsLog.error('appsflyer session start failed', error, stackTrace);
      }
    });

    AppsFlyerBootstrap.ready = true;
    AnalyticsLog.info('appsflyer initialized');
  } catch (error, stackTrace) {
    AnalyticsLog.error('appsflyer bootstrap failed', error, stackTrace);
    AppsFlyerBootstrap.ready = false;
  }
}
