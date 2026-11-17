import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_controller.dart';
import '../../features/auth/auth_state.dart';
import 'analytics_config.dart';
import 'analytics_service.dart';
import 'analytics_sink.dart';
import 'analytics_user.dart';
import 'composite_analytics.dart';
import 'noop_analytics_service.dart';

final analyticsSinksProvider = Provider<List<AnalyticsSink>>((ref) => const []);

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