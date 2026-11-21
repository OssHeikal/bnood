import 'package:bnood/core/analytics/domain/analytics_event.dart';
import 'package:bnood/core/analytics/domain/analytics_service.dart';
import 'package:bnood/core/analytics/domain/analytics_user.dart';

class FakeAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> events = [];
  final List<AnalyticsUser?> users = [];

  @override
  Future<void> track(AnalyticsEvent event) async {
    events.add(event);
  }

  @override
  Future<void> setUser(AnalyticsUser? user) async {
    users.add(user);
  }
}
