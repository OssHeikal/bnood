import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/agreements_api.dart';
import '../storage/session_store.dart';
import '../providers_api/providers_riverpod.dart';
import 'agreements_repository.dart';

final appAgreementsApiProvider = Provider<AgreementsApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = AgreementsApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});

final appAgreementsRepositoryProvider = Provider<AgreementsRepository>((ref) {
  return AgreementsRepository(ref.watch(appAgreementsApiProvider));
});

/// Online agreements CRUD (same gate as directory providers).
final remoteAgreementsEnabledProvider = remoteProvidersEnabledProvider;
