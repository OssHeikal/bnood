import 'package:flutter/foundation.dart';

abstract final class AnalyticsConfig {
  static const enabled = bool.fromEnvironment(
    'ANALYTICS_ENABLED',
    defaultValue: kReleaseMode,
  );

  static const appsFlyerDevKey = String.fromEnvironment('APPSFLYER_DEV_KEY');

  static const appsFlyerIosAppId = String.fromEnvironment(
    'APPSFLYER_IOS_APP_ID',
    defaultValue: '6832033457',
  );
}
