import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/vouchers_api.dart';
import '../storage/session_store.dart';
import '../../features/auth/auth_controller.dart';
import 'vouchers_repository.dart';

final vouchersApiProvider = Provider<VouchersApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = VouchersApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});

final vouchersRepositoryProvider = Provider<VouchersRepository>((ref) {
  return VouchersRepository(ref.watch(vouchersApiProvider));
});

/// Signed-in profile-complete sessions use the online vouchers API.
final remoteVouchersEnabledProvider = Provider<bool>((ref) {
  final auth = ref.watch(authControllerProvider);
  final user = auth.user;
  if (user == null || !auth.isAuthenticated) return false;
  return user.hasCompleteName;
});
