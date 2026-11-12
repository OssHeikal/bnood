import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/subscription_api.dart';
import '../storage/session_store.dart';
import '../providers/settings_provider.dart';
import '../../features/auth/auth_controller.dart';
import 'app_subscription.dart';

final subscriptionApiProvider = Provider<SubscriptionApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = SubscriptionApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});

final subscriptionProvider =
    AsyncNotifierProvider<SubscriptionNotifier, AppSubscriptionSnapshot?>(SubscriptionNotifier.new);

class SubscriptionNotifier extends AsyncNotifier<AppSubscriptionSnapshot?> {
  @override
  Future<AppSubscriptionSnapshot?> build() async {
    final auth = ref.watch(authControllerProvider);
    if (!auth.isAuthenticated) return null;
    return _load();
  }

  Future<AppSubscriptionSnapshot?> _load() async {
    try {
      final languageCode = ref.read(localeProvider).languageCode;
      return await ref.read(subscriptionApiProvider).getSubscription(languageCode: languageCode);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> refreshSilently() async {
    final auth = ref.read(authControllerProvider);
    if (!auth.isAuthenticated) {
      state = const AsyncData(null);
      return;
    }
    final previous = state.valueOrNull;
    try {
      final next = await _load();
      state = AsyncData(next);
    } catch (e, st) {
      if (previous != null) {
        state = AsyncData(previous);
      } else {
        state = AsyncError(e, st);
      }
    }
  }

  Future<void> refresh() async {
    final auth = ref.read(authControllerProvider);
    if (!auth.isAuthenticated) {
      state = const AsyncData(null);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

/// Fast read helpers for gating UI.
final subscriptionSurfacesEnabledProvider = Provider<bool>((ref) {
  final value = ref.watch(subscriptionProvider).valueOrNull;
  return value?.showSurfaces ?? false;
});

final subscriptionEntitlementsProvider = Provider<AppSubscriptionEntitlements?>((ref) {
  return ref.watch(subscriptionProvider).valueOrNull?.entitlements;
});
