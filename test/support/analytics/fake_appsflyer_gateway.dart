import 'package:bnood/core/analytics/appsflyer/appsflyer_gateway.dart';

class FakeAppsFlyerGateway implements AppsFlyerGateway {
  final List<({String name, Map<String, dynamic>? parameters})> events = [];
  final List<String?> customerUserIds = [];
  final List<Map<String, String>> userDataSets = [];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    events.add((name: name, parameters: parameters));
  }

  @override
  Future<void> setCustomerUserId(String? customerId) async {
    customerUserIds.add(customerId);
  }

  @override
  Future<void> setUserData(Map<String, String> data) async {
    userDataSets.add(data);
  }
}