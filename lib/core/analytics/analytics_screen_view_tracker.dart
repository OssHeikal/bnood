import 'package:flutter/widgets.dart';

import 'analytics_screen_name.dart';

typedef ScreenViewEmit = void Function(String screenName);

/// Dedupes screen views across root and shell-branch navigators.
class AnalyticsScreenViewTracker {
  AnalyticsScreenViewTracker(this._emit);

  final ScreenViewEmit _emit;
  String? _lastScreenName;

  @visibleForTesting
  String? get lastScreenName => _lastScreenName;

  void consider(Route<dynamic>? route, {required bool requireActive}) {
    if (route == null) return;
    if (requireActive && !route.isActive) return;
    final screenName = analyticsScreenNameForRoute(route);
    if (screenName == null) return;
    if (screenName == _lastScreenName) return;
    _lastScreenName = screenName;
    _emit(screenName);
  }

  @visibleForTesting
  void reset() => _lastScreenName = null;
}