import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/clients_api.dart';
import '../storage/session_store.dart';
import '../../features/auth/auth_controller.dart';
import 'clients_repository.dart';

final clientsApiProvider = Provider<ClientsApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = ClientsApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});

final clientsRepositoryProvider = Provider<ClientsRepository>((ref) {
  return ClientsRepository(ref.watch(clientsApiProvider));
});

/// Whether signed-in clients should use the online API (not Drift).
final remoteClientsEnabledProvider = Provider<bool>((ref) {
  final auth = ref.watch(authControllerProvider);
  final user = auth.user;
  if (user == null || !auth.isAuthenticated) return false;
  return user.hasCompleteName;
});
