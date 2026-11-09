import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/session_store.dart';
import 'auth_api.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = AuthApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});
