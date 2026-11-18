import 'package:flutter/widgets.dart';

import 'analytics_screen_view_tracker.dart';

enum AnalyticsRouteObserverScope {
  /// Full-screen stack on the root navigator (detail routes, auth, etc.).
  root,

  /// Tab stacks inside [StatefulShellRoute]; ignore offstage branches.
  shellBranch,
}

/// Emits deduped [ScreenViewed] events via [AnalyticsScreenViewTracker].
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver({
    required AnalyticsScreenViewTracker tracker,
    required this.scope,
  }) : _tracker = tracker;

  final AnalyticsScreenViewTracker _tracker;
  final AnalyticsRouteObserverScope scope;

  bool get _requireActive => scope == AnalyticsRouteObserverScope.shellBranch;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _tracker.consider(route, requireActive: _requireActive);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _tracker.consider(previousRoute, requireActive: _requireActive);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _tracker.consider(newRoute, requireActive: _requireActive);
  }
}

abstract final class AnalyticsRouteObservers {
  static List<NavigatorObserver> forRoot(AnalyticsScreenViewTracker tracker) => [
        AnalyticsRouteObserver(tracker: tracker, scope: AnalyticsRouteObserverScope.root),
      ];

  static List<NavigatorObserver> forShellBranch(AnalyticsScreenViewTracker tracker) => [
        AnalyticsRouteObserver(tracker: tracker, scope: AnalyticsRouteObserverScope.shellBranch),
      ];
}