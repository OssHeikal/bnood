import 'analytics_event.dart';
import 'analytics_log.dart';
import 'analytics_service.dart';
import 'analytics_sink.dart';
import 'analytics_user.dart';

class CompositeAnalytics implements AnalyticsService {
  CompositeAnalytics({required List<AnalyticsSink> sinks}) : _sinks = List.unmodifiable(sinks);

  final List<AnalyticsSink> _sinks;

  @override
  Future<void> track(AnalyticsEvent event) async {
    final accepted = <String>[];
    for (final sink in _sinks) {
      if (!sink.accepts(event)) continue;
      final label = _sinkLabel(sink);
      accepted.add(label);
      try {
        await sink.track(event);
      } catch (error, stackTrace) {
        AnalyticsLog.error('$label track ${event.name} failed', error, stackTrace);
      }
    }
    final targets = accepted.isEmpty ? 'none' : accepted.join(', ');
    AnalyticsLog.info('track ${AnalyticsLog.event(event)} -> $targets');
  }

  @override
  Future<void> setUser(AnalyticsUser? user) async {
    final labels = _sinks.map(_sinkLabel).join(', ');
    for (final sink in _sinks) {
      try {
        await sink.setUser(user);
      } catch (error, stackTrace) {
        AnalyticsLog.error('${_sinkLabel(sink)} setUser failed', error, stackTrace);
      }
    }
    AnalyticsLog.info('setUser ${AnalyticsLog.user(user)} -> $labels');
  }
}

String _sinkLabel(AnalyticsSink sink) {
  if (sink is FirebaseAnalyticsSink) return 'firebase';
  if (sink is AppsFlyerAnalyticsSink) return 'appsflyer';
  return sink.runtimeType.toString();
}
