import 'analytics_event.dart';
import 'analytics_sink.dart';
import 'analytics_user.dart';
import 'firebase_analytics_gateway.dart';
import 'firebase_ga_event_mapping.dart';
import 'ga_user_properties.dart';

final class RemoteFirebaseAnalyticsSink extends FirebaseAnalyticsSink {
  RemoteFirebaseAnalyticsSink({required FirebaseAnalyticsGateway gateway}) : _gateway = gateway;

  final FirebaseAnalyticsGateway _gateway;

  @override
  Future<void> track(AnalyticsEvent event) async {
    await _gateway.logEvent(
      name: firebaseGaEventName(event),
      parameters: firebaseGaEventParameters(event),
    );
  }

  @override
  Future<void> setUser(AnalyticsUser? user) async {
    if (user == null) {
      await _gateway.setUserId(null);
      await _gateway.setUserProperty(name: GaUserProperties.accountName, value: null);
      await _gateway.setUserProperty(name: GaUserProperties.accountPhone, value: null);
      return;
    }

    await _gateway.setUserId(user.id);
    await _gateway.setUserProperty(
      name: GaUserProperties.accountName,
      value: truncateGaUserProperty(user.name),
    );
    await _gateway.setUserProperty(
      name: GaUserProperties.accountPhone,
      value: truncateGaUserProperty(user.phone),
    );
  }
}