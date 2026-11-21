import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/vouchers/data/vouchers_api.dart';
import 'package:bnood/core/storage/session_store.dart';
import 'package:bnood/features/vouchers/data/vouchers_repository.dart';

final vouchersApiProvider = Provider<VouchersApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = VouchersApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});

final vouchersRepositoryProvider = Provider<VouchersRepository>((ref) {
  return VouchersRepository(ref.watch(vouchersApiProvider));
});
