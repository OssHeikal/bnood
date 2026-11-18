import 'package:flutter/foundation.dart';

import 'analytics_event.dart';
import 'analytics_service.dart';
import 'analytics_sink.dart';
import 'analytics_user.dart';

class CompositeAnalytics implements AnalyticsService {
  CompositeAnalytics({required List<AnalyticsSink> sinks}) : _sinks = List.unmodifiable(sinks);

  final List<AnalyticsSink> _sinks;

  @override
  Future<void> track(AnalyticsEvent event) async {
    for (final sink in _sinks) {
      if (!sink.accepts(event)) continue;
      try {
        await sink.track(event);
      } catch (error, stackTrace) {
        debugPrint('Analytics sink track failed: $error\n$stackTrace');
      }
    }
  }

  @override
  Future<void> setUser(AnalyticsUser? user) async {
    for (final sink in _sinks) {
      try {
        await sink.setUser(user);
      } catch (error, stackTrace) {
        debugPrint('Analytics sink setUser failed: $error\n$stackTrace');
      }
    }
  }
}