import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import '../../../network/push/push_platform.dart';
import '../appsflyer/appsflyer_bootstrap.dart';
import '../appsflyer/appsflyer_gateway.dart';
import '../appsflyer/appsflyer_gateway_impl.dart';
import '../appsflyer/remote_appsflyer_analytics_sink.dart';
import '../domain/analytics_config.dart';
import '../domain/analytics_event.dart';
import '../domain/analytics_log.dart';
import '../domain/analytics_service.dart';
import '../domain/analytics_sink.dart';
import '../domain/analytics_user.dart';
import '../domain/composite_analytics.dart';
import '../domain/noop_analytics_service.dart';
import '../firebase/firebase_analytics_gateway.dart';
import '../firebase/firebase_analytics_gateway_impl.dart';
import '../firebase/remote_firebase_analytics_sink.dart';
import '../routing/analytics_screen_view_tracker.dart';
import 'analytics_track.dart';

final analyticsScreenViewTrackerProvider = Provider<AnalyticsScreenViewTracker>(
  (ref) {
    return AnalyticsScreenViewTracker((screenName) {
      trackAnalyticsEvent(ref, ScreenViewed(screenName: screenName));
    });
  },
);

/// Null when Firebase is not initialized on this platform (web, desktop, tests).
final firebaseAnalyticsGatewayProvider = Provider<FirebaseAnalyticsGateway?>((
  ref,
) {
  if (!pushMessagingSupported) return null;
  return FirebaseAnalyticsGatewayImpl();
});

final appsFlyerGatewayProvider = Provider<AppsFlyerGateway?>((ref) {
  if (!pushMessagingSupported) return null;
  if (AnalyticsConfig.appsFlyerDevKey.isEmpty) return null;
  if (!AppsFlyerBootstrap.sessionStarted) return null;
  return AppsFlyerGatewayImpl();
});

final analyticsSinksProvider = Provider<List<AnalyticsSink>>((ref) {
  final sinks = <AnalyticsSink>[];
  final firebase = ref.watch(firebaseAnalyticsGatewayProvider);
  if (firebase != null) {
    sinks.add(RemoteFirebaseAnalyticsSink(gateway: firebase));
    AnalyticsLog.info('firebase sink ready');
  } else {
    AnalyticsLog.info('firebase sink unavailable');
  }
  final appsFlyer = ref.watch(appsFlyerGatewayProvider);
  if (appsFlyer != null) {
    sinks.add(RemoteAppsFlyerAnalyticsSink(gateway: appsFlyer));
    AnalyticsLog.info('appsflyer sink ready');
  } else if (AnalyticsConfig.appsFlyerDevKey.isNotEmpty) {
    AnalyticsLog.info(
      'appsflyer sink unavailable (sessionStarted=${AppsFlyerBootstrap.sessionStarted})',
    );
  }
  return sinks;
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  if (!AnalyticsConfig.enabled) {
    AnalyticsLog.info('off (pass --dart-define=ANALYTICS_ENABLED=true)');
    return const NoopAnalyticsService();
  }
  final sinks = ref.watch(analyticsSinksProvider);
  if (sinks.isEmpty) {
    AnalyticsLog.info('no sinks');
    return const NoopAnalyticsService();
  }
  AnalyticsLog.info('active sinks: ${sinks.length}');
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
