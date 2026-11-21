import 'package:firebase_analytics/firebase_analytics.dart';

import '../domain/analytics_log.dart';
import 'firebase_analytics_gateway.dart';

class FirebaseAnalyticsGatewayImpl implements FirebaseAnalyticsGateway {
  FirebaseAnalyticsGatewayImpl({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    AnalyticsLog.info('firebase logEvent $name $parameters');
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  @override
  Future<void> logScreenView({required String screenName}) async {
    AnalyticsLog.info('firebase logScreenView $screenName');
    await _analytics.logScreenView(screenName: screenName);
  }

  @override
  Future<void> setUserId(String? id) => _analytics.setUserId(id: id);

  @override
  Future<void> setUserProperty({required String name, String? value}) =>
      _analytics.setUserProperty(name: name, value: value);
}
