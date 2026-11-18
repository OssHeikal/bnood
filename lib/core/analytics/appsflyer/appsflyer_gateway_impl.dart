import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';

import 'appsflyer_gateway.dart';

class AppsFlyerGatewayImpl implements AppsFlyerGateway {
  AppsFlyerGatewayImpl({AppsFlyerSdk? sdk}) : _sdk = sdk ?? AppsFlyerSdk.instance;

  final AppsFlyerSdk _sdk;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _sdk.logEvent(name, eventValues: parameters);
    } catch (error, stackTrace) {
      debugPrint('AppsFlyer logEvent failed: $error\n$stackTrace');
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
      debugPrint('AppsFlyer setCustomerUserId failed: $error\n$stackTrace');
    }
  }

  @override
  Future<void> setUserData(Map<String, String> data) async {
    try {
      await _sdk.setAdditionalData(data);
    } catch (error, stackTrace) {
      debugPrint('AppsFlyer setAdditionalData failed: $error\n$stackTrace');
    }
  }
}