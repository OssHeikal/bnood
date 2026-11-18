import 'analytics_event.dart';
import 'analytics_log.dart';
import 'analytics_service.dart';
import 'analytics_user.dart';

class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> track(AnalyticsEvent event) async {
    AnalyticsLog.info('dropped ${AnalyticsLog.event(event)}');
  }

  @override
  Future<void> setUser(AnalyticsUser? user) async {
    AnalyticsLog.info('dropped setUser ${AnalyticsLog.user(user)}');
  }
}
