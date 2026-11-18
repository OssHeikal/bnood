import 'analytics_event.dart';

const int _gaMaxEventNameLength = 40;
const int _gaMaxParamNameLength = 40;

/// Maps [AnalyticsEvent] fields to Firebase `logEvent` arguments.
Map<String, Object>? firebaseGaEventParameters(AnalyticsEvent event) {
  if (event.params.isEmpty) return null;

  final mapped = <String, Object>{};
  for (final entry in event.params.entries) {
    final key = _gaParamName(entry.key);
    mapped[key] = _gaParamValue(entry.value);
  }
  return mapped;
}

String firebaseGaEventName(AnalyticsEvent event) {
  final name = event.name;
  assert(name.length <= _gaMaxEventNameLength);
  return name;
}

String _gaParamName(String name) {
  assert(name.length <= _gaMaxParamNameLength);
  return name;
}

Object _gaParamValue(Object value) {
  if (value is bool) {
    return value ? 'true' : 'false';
  }
  assert(value is String || value is num);
  return value;
}