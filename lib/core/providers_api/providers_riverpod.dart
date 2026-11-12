import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/providers_api.dart';
import '../storage/session_store.dart';
import '../../features/auth/auth_controller.dart';
import 'providers_repository.dart';

final appProvidersApiProvider = Provider<ProvidersApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = ProvidersApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});

final appProvidersRepositoryProvider = Provider<ProvidersRepository>((ref) {
  return ProvidersRepository(ref.watch(appProvidersApiProvider));
});

/// Whether directory provider CRUD should use the online API (not Drift).
final remoteProvidersEnabledProvider = Provider<bool>((ref) {
  final auth = ref.watch(authControllerProvider);
  final user = auth.user;
  if (user == null || !auth.isAuthenticated) return false;
  return user.hasCompleteName;
});
