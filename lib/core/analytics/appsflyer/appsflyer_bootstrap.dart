import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';

import '../../push/push_platform.dart';
import '../domain/analytics_config.dart';

abstract final class AppsFlyerBootstrap {
  static bool ready = false;
}

/// Initializes AppsFlyer on mobile when [AnalyticsConfig.appsFlyerDevKey] is set.
///
/// On iOS, requests ATT when still undetermined, then starts the first session.
Future<void> bootstrapAppsFlyer() async {
  AppsFlyerBootstrap.ready = false;
  if (!pushMessagingSupported) return;

  final devKey = AnalyticsConfig.appsFlyerDevKey;
  if (devKey.isEmpty) return;

  try {
    final sdk = AppsFlyerSdk.instance;
    final iosAppId = AnalyticsConfig.appsFlyerIosAppId;
    await sdk.init(
      devKey: devKey,
      appId: Platform.isIOS ? iosAppId : null,
    );

    var attHandled = false;
    await sdk.registerSessionReadyListener(() async {
      if (!attHandled && Platform.isIOS) {
        final status = await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
        attHandled = true;
      }
      await sdk.start();
    });

    AppsFlyerBootstrap.ready = true;
  } catch (error, stackTrace) {
    debugPrint('AppsFlyer bootstrap failed: $error\n$stackTrace');
    AppsFlyerBootstrap.ready = false;
  }
}