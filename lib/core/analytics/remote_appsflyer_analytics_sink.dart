import 'analytics_event.dart';
import 'analytics_sink.dart';
import 'analytics_user.dart';
import 'analytics_user_vendor_data.dart';
import 'appsflyer_event_mapping.dart';
import 'appsflyer_gateway.dart';
import 'ga_user_properties.dart';

final class RemoteAppsFlyerAnalyticsSink extends AppsFlyerAnalyticsSink {
  RemoteAppsFlyerAnalyticsSink({required AppsFlyerGateway gateway}) : _gateway = gateway;

  final AppsFlyerGateway _gateway;

  @override
  Future<void> track(AnalyticsEvent event) async {
    if (!appsFlyerShouldEmitEvent(event)) return;
    await _gateway.logEvent(name: appsFlyerCompleteRegistrationEvent, parameters: const {});
  }

  @override
  Future<void> setUser(AnalyticsUser? user) async {
    if (user == null) {
      await _gateway.setCustomerUserId('');
      await _gateway.setUserData(const {});
      return;
    }

    await _gateway.setCustomerUserId(user.id);
    await _gateway.setUserData(vendorUserDataPayload(user));
  }
}