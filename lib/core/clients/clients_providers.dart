import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/clients_api.dart';
import '../storage/session_store.dart';
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