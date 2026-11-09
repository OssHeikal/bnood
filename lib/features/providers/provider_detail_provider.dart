import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/agreements/agreements_riverpod.dart';
import '../../core/api/auth_api_exception.dart';
import '../../core/providers_api/app_provider_record.dart';
import '../../core/providers_api/providers_riverpod.dart';
import 'provider_detail_snapshot.dart';

final providerDetailProvider =
    AsyncNotifierProvider.family<ProviderDetailNotifier, ProviderDetailSnapshot, String>(
  ProviderDetailNotifier.new,
);

class ProviderDetailNotifier extends FamilyAsyncNotifier<ProviderDetailSnapshot, String> {
  int _reloadSeq = 0;

  @override
  Future<ProviderDetailSnapshot> build(String providerId) => loadSnapshot(providerId);

  Future<void> refreshSilently() async {
    final previous = state.valueOrNull;
    final seq = ++_reloadSeq;
    if (previous != null) {
      state = AsyncValue<ProviderDetailSnapshot>.loading().copyWithPrevious(AsyncValue.data(previous));
    } else if (!state.hasValue) {
      state = const AsyncValue.loading();
    }
    try {
      final next = await loadSnapshot(arg);
      if (seq != _reloadSeq) return;
      state = AsyncValue.data(next);
    } catch (error, stackTrace) {
      if (seq != _reloadSeq) return;
      if (previous != null) {
        state = AsyncValue<ProviderDetailSnapshot>.error(error, stackTrace).copyWithPrevious(
          AsyncValue.data(previous),
        );
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<ProviderDetailSnapshot> loadSnapshot(String providerId) async {
    final providersRepo = ref.read(appProvidersRepositoryProvider);
    AppProvider provider;
    try {
      provider = await providersRepo.getProvider(providerId);
    } on AuthApiException catch (e) {
      if (e.isNotFound || e.isProviderNotFound) throw const ProviderDetailNotFound();
      rethrow;
    }

    var clientAgreements = <ProviderDetailClientRow>[];
    if (provider.type == AppProviderType.craftsman && ref.read(remoteAgreementsEnabledProvider)) {
      final agreementsRepo = ref.read(appAgreementsRepositoryProvider);
      try {
        final agreements = await agreementsRepo.listAllProviderAgreements(providerId);
        clientAgreements = agreements
            .map(
              (a) => ProviderDetailClientRow(
                agreement: a,
                clientName: a.clientName ?? '—',
              ),
            )
            .toList()
          ..sort((a, b) => a.clientName.compareTo(b.clientName));
      } on AuthApiException catch (e) {
        if (e.isProviderNotCraftsman) {
          clientAgreements = const [];
        } else {
          rethrow;
        }
      }
    }

    return ProviderDetailSnapshot(
      provider: provider,
      clientAgreements: clientAgreements,
    );
  }
}
