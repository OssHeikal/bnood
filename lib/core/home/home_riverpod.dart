import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/home_api.dart';
import '../storage/session_store.dart';
import 'home_repository.dart';

final homeApiProvider = Provider<HomeApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = HomeApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(homeApiProvider));
});
