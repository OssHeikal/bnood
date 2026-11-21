import 'analytics_accept_policies.dart';
import 'analytics_event.dart';
import 'analytics_user.dart';

abstract interface class AnalyticsSink {
  bool accepts(AnalyticsEvent event);

  Future<void> track(AnalyticsEvent event);

  Future<void> setUser(AnalyticsUser? user);
}

/// Vendor sinks in later phases extend this and implement [track] / [setUser].
abstract base class PolicyAnalyticsSink implements AnalyticsSink {
  bool Function(AnalyticsEvent event) get acceptPolicy;

  @override
  bool accepts(AnalyticsEvent event) => acceptPolicy(event);
}

/// Firebase Analytics adapter (phase 2) plugs in [firebaseAcceptPolicy].
abstract base class FirebaseAnalyticsSink extends PolicyAnalyticsSink {
  @override
  bool Function(AnalyticsEvent event) get acceptPolicy => firebaseAcceptPolicy;
}

/// AppsFlyer adapter (phase 6) plugs in [appsFlyerAcceptPolicy].
abstract base class AppsFlyerAnalyticsSink extends PolicyAnalyticsSink {
  @override
  bool Function(AnalyticsEvent event) get acceptPolicy => appsFlyerAcceptPolicy;
}
