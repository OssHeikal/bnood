import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/core/data/storage/session_store.dart';

import 'package:bnood/features/clients/data/clients_api.dart';
import 'package:bnood/features/clients/data/clients_repository.dart';

final clientsApiProvider = Provider<ClientsApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = ClientsApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});

final clientsRepositoryProvider = Provider<ClientsRepository>((ref) {
  return ClientsRepository(ref.watch(clientsApiProvider));
});
