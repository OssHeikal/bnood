import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/providers/data/providers_api.dart';
import 'package:bnood/core/data/storage/session_store.dart';
import 'package:bnood/features/providers/data/providers_repository.dart';

final appProvidersApiProvider = Provider<ProvidersApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = ProvidersApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});

final appProvidersRepositoryProvider = Provider<ProvidersRepository>((ref) {
  return ProvidersRepository(ref.watch(appProvidersApiProvider));
});
