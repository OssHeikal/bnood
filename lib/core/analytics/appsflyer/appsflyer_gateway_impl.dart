import 'package:appsflyer_sdk/appsflyer_sdk.dart';

import '../domain/analytics_log.dart';
import 'appsflyer_gateway.dart';

class AppsFlyerGatewayImpl implements AppsFlyerGateway {
  AppsFlyerGatewayImpl({AppsFlyerSdk? sdk})
    : _sdk = sdk ?? AppsFlyerSdk.instance;

  final AppsFlyerSdk _sdk;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      AnalyticsLog.info('appsflyer logEvent $name $parameters');
      await _sdk.logEvent(name, eventValues: parameters);
    } catch (error, stackTrace) {
      AnalyticsLog.error('appsflyer logEvent failed', error, stackTrace);
    }
  }

  @override
  Future<void> setCustomerUserId(String? customerId) async {
    try {
      if (customerId == null || customerId.isEmpty) {
        await _sdk.setCustomerUserId('');
        return;
      }
      await _sdk.setCustomerUserId(customerId);
    } catch (error, stackTrace) {
      AnalyticsLog.error(
        'appsflyer setCustomerUserId failed',
        error,
        stackTrace,
      );
    }
  }

  @override
  Future<void> setUserData(Map<String, String> data) async {
    try {
      await _sdk.setAdditionalData(data);
    } catch (error, stackTrace) {
      AnalyticsLog.error(
        'appsflyer setAdditionalData failed',
        error,
        stackTrace,
      );
    }
  }
}
