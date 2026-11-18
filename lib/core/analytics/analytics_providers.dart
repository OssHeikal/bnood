import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_controller.dart';
import '../../features/auth/auth_state.dart';
import '../push/push_platform.dart';
import 'analytics_config.dart';
import 'analytics_event.dart';
import 'analytics_route_observer.dart';
import 'analytics_screen_view_tracker.dart';
import 'analytics_service.dart';
import 'analytics_track.dart';
import 'analytics_sink.dart';
import 'analytics_user.dart';
import 'composite_analytics.dart';
import 'appsflyer_bootstrap.dart';
import 'appsflyer_gateway.dart';
import 'appsflyer_gateway_impl.dart';
import 'firebase_analytics_gateway.dart';
import 'firebase_analytics_gateway_impl.dart';
import 'noop_analytics_service.dart';
import 'remote_appsflyer_analytics_sink.dart';
import 'remote_firebase_analytics_sink.dart';

final analyticsScreenViewTrackerProvider = Provider<AnalyticsScreenViewTracker>((ref) {
  return AnalyticsScreenViewTracker((screenName) {
    trackAnalyticsEvent(ref, ScreenViewed(screenName: screenName));
  });
});

/// Null when Firebase is not initialized on this platform (web, desktop, tests).
final firebaseAnalyticsGatewayProvider = Provider<FirebaseAnalyticsGateway?>((ref) {
  if (!pushMessagingSupported) return null;
  return FirebaseAnalyticsGatewayImpl();
});

final appsFlyerGatewayProvider = Provider<AppsFlyerGateway?>((ref) {
  if (!pushMessagingSupported) return null;
  if (AnalyticsConfig.appsFlyerDevKey.isEmpty) return null;
  if (!AppsFlyerBootstrap.ready) return null;
  return AppsFlyerGatewayImpl();
});

final analyticsSinksProvider = Provider<List<AnalyticsSink>>((ref) {
  final sinks = <AnalyticsSink>[];
  final firebase = ref.watch(firebaseAnalyticsGatewayProvider);
  if (firebase != null) {
    sinks.add(RemoteFirebaseAnalyticsSink(gateway: firebase));
  }
  final appsFlyer = ref.watch(appsFlyerGatewayProvider);
  if (appsFlyer != null) {
    sinks.add(RemoteAppsFlyerAnalyticsSink(gateway: appsFlyer));
  }
  return sinks;
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  if (!AnalyticsConfig.enabled) {
    return const NoopAnalyticsService();
  }
  final sinks = ref.watch(analyticsSinksProvider);
  if (sinks.isEmpty) {
    return const NoopAnalyticsService();
  }
  return CompositeAnalytics(sinks: sinks);
});

AnalyticsUser? _analyticsUserFromAuth(AuthState? auth) {
  if (auth == null || !auth.isAuthenticated) return null;
  final user = auth.user;
  if (user == null) return null;
  return AnalyticsUser(id: user.id, name: user.name, phone: user.phone);
}

String? _authAnalyticsIdentity(AuthState? auth) {
  if (auth == null || !auth.isAuthenticated) return null;
  return auth.user?.id;
}

/// Mirrors analytics user identity to sinks when auth changes.
final analyticsLifecycleProvider = Provider<void>((ref) {
  Future<void> sync(AuthState? auth) async {
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.setUser(_analyticsUserFromAuth(auth));
  }

  final initial = ref.read(authControllerProvider);
  Future.microtask(() => sync(initial));

  ref.listen(authControllerProvider, (previous, next) {
    if (_authAnalyticsIdentity(previous) == _authAnalyticsIdentity(next) &&
        previous?.isAuthenticated == next.isAuthenticated) {
      return;
    }
    Future.microtask(() => sync(next));
  });
});