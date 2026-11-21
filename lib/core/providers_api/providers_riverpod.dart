import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/providers_api.dart';
import '../storage/session_store.dart';
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