import 'package:bnood/core/analytics/firebase/firebase_analytics_gateway.dart';

class LoggedGaEvent {
  const LoggedGaEvent({required this.name, this.parameters});

  final String name;
  final Map<String, Object>? parameters;
}

class FakeFirebaseAnalyticsGateway implements FirebaseAnalyticsGateway {
  final List<LoggedGaEvent> events = [];
  final List<String?> userIds = [];
  final List<MapEntry<String, String?>> userProperties = [];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    events.add(LoggedGaEvent(name: name, parameters: parameters));
  }

  @override
  Future<void> setUserId(String? id) async {
    userIds.add(id);
  }

  @override
  Future<void> setUserProperty({
    required String name,
    String? value,
  }) async {
    userProperties.add(MapEntry(name, value));
  }
}