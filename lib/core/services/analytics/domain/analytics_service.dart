import 'analytics_event.dart';
import 'analytics_user.dart';

abstract interface class AnalyticsService {
  Future<void> track(AnalyticsEvent event);

  Future<void> setUser(AnalyticsUser? user);
}
