import '../domain/analytics_event.dart';
import '../domain/analytics_sink.dart';
import '../domain/analytics_user.dart';
import '../domain/analytics_user_vendor_data.dart';
import 'firebase_analytics_gateway.dart';
import 'firebase_ga_event_mapping.dart';
import 'ga_user_properties.dart';

final class RemoteFirebaseAnalyticsSink extends FirebaseAnalyticsSink {
  RemoteFirebaseAnalyticsSink({required FirebaseAnalyticsGateway gateway}) : _gateway = gateway;

  final FirebaseAnalyticsGateway _gateway;

  @override
  Future<void> track(AnalyticsEvent event) async {
    if (event is ScreenViewed) {
      await _gateway.logScreenView(screenName: event.screenName);
      return;
    }
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
    for (final entry in vendorUserDataPayload(user).entries) {
      await _gateway.setUserProperty(name: entry.key, value: entry.value);
    }
  }
}