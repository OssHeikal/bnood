import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/providers/data/agreements_api.dart';
import 'package:bnood/core/data/storage/session_store.dart';
import 'package:bnood/features/providers/data/agreements_repository.dart';

final appAgreementsApiProvider = Provider<AgreementsApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = AgreementsApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});

final appAgreementsRepositoryProvider = Provider<AgreementsRepository>((ref) {
  return AgreementsRepository(ref.watch(appAgreementsApiProvider));
});
