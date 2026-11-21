import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';

import '../../push/push_platform.dart';
import '../domain/analytics_config.dart';
import '../domain/analytics_log.dart';

abstract final class AppsFlyerBootstrap {
  /// First Launch reported to AppsFlyer (required before in-app events count).
  static bool sessionStarted = false;

  /// Optional hook (e.g. invalidate Riverpod) when [sessionStarted] flips to true.
  static void Function()? onSessionStarted;
}

Future<void> _startAppsFlyerSessionOnce(AppsFlyerSdk sdk) async {
  if (AppsFlyerBootstrap.sessionStarted) return;

  if (Platform.isIOS) {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    AnalyticsLog.info('att status $status');
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
      AnalyticsLog.info(
        'att after prompt ${await AppTrackingTransparency.trackingAuthorizationStatus}',
      );
    }
  }

  await sdk.start(awaitResponse: kDebugMode);
  AppsFlyerBootstrap.sessionStarted = true;
  AnalyticsLog.info('appsflyer session started');
  AppsFlyerBootstrap.onSessionStarted?.call();
}

/// Initializes AppsFlyer on mobile when [AnalyticsConfig.appsFlyerDevKey] is set.
///
/// On iOS, requests ATT when still undetermined, then starts the first session
/// from the session-ready callback (and falls back when the SDK is already ready).
Future<void> bootstrapAppsFlyer() async {
  AppsFlyerBootstrap.sessionStarted = false;
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

    if (kDebugMode) {
      await sdk.enableDebug(true);
      AnalyticsLog.info('appsflyer debug logging on');
    }

    final iosAppId = AnalyticsConfig.appsFlyerIosAppId;
    await sdk.init(devKey: devKey, appId: Platform.isIOS ? iosAppId : null);
    AnalyticsLog.info('appsflyer init ok (iosAppId=$iosAppId)');

    await sdk.registerConversionListener(
      onConversionDataSuccess: (data) {
        AnalyticsLog.info('appsflyer gcd success $data');
      },
      onConversionDataFail: (error) {
        AnalyticsLog.info('appsflyer gcd failure $error');
      },
    );

    final firstSession = Completer<void>();

    await sdk.registerSessionReadyListener(() async {
      try {
        await _startAppsFlyerSessionOnce(sdk);
      } catch (error, stackTrace) {
        AnalyticsLog.error('appsflyer session start failed', error, stackTrace);
      } finally {
        if (!firstSession.isCompleted) {
          firstSession.complete();
        }
      }
    });

    if (!AppsFlyerBootstrap.sessionStarted && await sdk.isSessionReady()) {
      try {
        await _startAppsFlyerSessionOnce(sdk);
      } catch (error, stackTrace) {
        AnalyticsLog.error('appsflyer session start failed', error, stackTrace);
      } finally {
        if (!firstSession.isCompleted) {
          firstSession.complete();
        }
      }
    }

    unawaited(
      Future<void>.delayed(const Duration(seconds: 8), () {
        if (!firstSession.isCompleted) {
          AnalyticsLog.info(
            'appsflyer session-ready wait timeout (continuing launch)',
          );
          firstSession.complete();
        }
      }),
    );

    await firstSession.future;
    AnalyticsLog.info(
      'appsflyer bootstrap done (sessionStarted=${AppsFlyerBootstrap.sessionStarted})',
    );
  } catch (error, stackTrace) {
    AnalyticsLog.error('appsflyer bootstrap failed', error, stackTrace);
    AppsFlyerBootstrap.sessionStarted = false;
  }
}
