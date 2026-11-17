import 'package:bnood/core/analytics/analytics_route_observer.dart';
import 'package:bnood/core/analytics/analytics_screen_name.dart';
import 'package:bnood/core/analytics/analytics_screen_view_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PageRoute<void> analyticsTestPageRoute(String name) => PageRouteBuilder<void>(
      settings: RouteSettings(name: name),
      pageBuilder: (_, _, _) => const SizedBox(),
    );

void main() {
  test('analyticsScreenNameForRoute uses path template, not ids', () {
    expect(analyticsScreenNameForRoute(analyticsTestPageRoute('/clients/:clientId')), '/clients/:clientId');
  });

  test('analyticsScreenNameForRoute ignores popup routes', () {
    expect(analyticsScreenNameForRoute(_TestPopupRoute()), isNull);
  });

  test('tracker dedupes identical screen names', () {
    final emitted = <String>[];
    final tracker = AnalyticsScreenViewTracker(emitted.add);
    final route = analyticsTestPageRoute('/home');

    tracker.consider(route, requireActive: false);
    tracker.consider(route, requireActive: false);

    expect(emitted, ['/home']);
  });

  test('tracker emits again after navigating away and back', () {
    final emitted = <String>[];
    final tracker = AnalyticsScreenViewTracker(emitted.add);
    final home = analyticsTestPageRoute('/home');
    final detail = analyticsTestPageRoute('/clients/:clientId');

    tracker.consider(home, requireActive: false);
    tracker.consider(detail, requireActive: false);
    tracker.consider(home, requireActive: false);

    expect(emitted, ['/home', '/clients/:clientId', '/home']);
  });

  test('root and branch observers share dedupe via tracker', () {
    final emitted = <String>[];
    final tracker = AnalyticsScreenViewTracker(emitted.add);
    final route = analyticsTestPageRoute('/clients');

    final root = AnalyticsRouteObserver(tracker: tracker, scope: AnalyticsRouteObserverScope.root);
    final branch = AnalyticsRouteObserver(tracker: tracker, scope: AnalyticsRouteObserverScope.shellBranch);

    root.didPush(route, null);
    root.didPush(route, null);
    branch.didPush(route, null);

    expect(emitted, ['/clients']);
  });
}

class _TestPopupRoute extends PopupRoute<void> {
  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      const SizedBox();

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;
}