/// Stages at most one cold-start notification tap (FCM or local) until navigation runs.
final class PushColdStartNavigation {
  Map<String, String>? _pending;
  Map<String, String>? _lastConsumed;
  bool _consumed = false;

  Map<String, String>? get pending => _pending;

  bool get hasPending => _pending != null && !_consumed;

  /// First non-null [fcm] or [local] wins; later calls are ignored until consumed.
  void stage({Map<String, String>? fcm, Map<String, String>? local}) {
    if (_consumed || _pending != null) return;
    final pick = (fcm != null && fcm.isNotEmpty)
        ? fcm
        : (local != null && local.isNotEmpty)
        ? local
        : null;
    if (pick == null) return;
    _pending = Map<String, String>.from(pick);
  }

  /// Removes and returns pending payload for navigation, marking it consumed.
  Map<String, String>? takePending() {
    if (_consumed || _pending == null) return null;
    final data = _pending!;
    _pending = null;
    _consumed = true;
    _lastConsumed = Map<String, String>.from(data);
    return data;
  }

  /// Skip [onMessageOpenedApp] when it duplicates an already-handled cold-start tap.
  bool shouldIgnoreOpenedApp(Map<String, String> data) {
    if (!_consumed || _lastConsumed == null) return false;
    return pushPayloadMapsEqual(_lastConsumed!, data);
  }
}

bool pushPayloadMapsEqual(Map<String, String> a, Map<String, String> b) {
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) return false;
  }
  return true;
}
