import 'package:bnood/core/analytics/domain/analytics_event.dart';
import 'package:bnood/core/analytics/domain/analytics_sink.dart';
import 'package:bnood/core/analytics/domain/analytics_user.dart';

class PolicyRecordingAnalyticsSink implements AnalyticsSink {
  PolicyRecordingAnalyticsSink(this.acceptPolicy);

  final bool Function(AnalyticsEvent event) acceptPolicy;

  final List<AnalyticsEvent> events = [];
  final List<AnalyticsUser?> users = [];

  @override
  bool accepts(AnalyticsEvent event) => acceptPolicy(event);

  @override
  Future<void> track(AnalyticsEvent event) async {
    events.add(event);
  }

  @override
  Future<void> setUser(AnalyticsUser? user) async {
    users.add(user);
  }
}

class ThrowingAnalyticsSink implements AnalyticsSink {
  ThrowingAnalyticsSink(this.acceptPolicy);

  final bool Function(AnalyticsEvent event) acceptPolicy;

  @override
  bool accepts(AnalyticsEvent event) => acceptPolicy(event);

  @override
  Future<void> track(AnalyticsEvent event) async {
    throw StateError('sink failed');
  }

  @override
  Future<void> setUser(AnalyticsUser? user) async {
    throw StateError('sink failed');
  }
}