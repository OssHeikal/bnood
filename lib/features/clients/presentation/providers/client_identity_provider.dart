import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/core/account/account_context_providers.dart';
import 'package:bnood/features/clients/data/client_identity_mapper.dart';
import 'package:bnood/core/data/storage/session_store.dart';
import 'package:bnood/features/clients/data/clients_providers.dart';
import 'package:bnood/features/clients/data/office_clients_api.dart';
import 'package:bnood/features/clients/presentation/models/client_identity_snapshot.dart';
final officeClientsApiProvider = Provider<OfficeClientsApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = OfficeClientsApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});

final clientIdentityProvider =
    AsyncNotifierProvider.family<ClientIdentityNotifier, ClientIdentitySnapshot, String>(
  ClientIdentityNotifier.new,
);

class ClientIdentityNotifier
    extends FamilyAsyncNotifier<ClientIdentitySnapshot, String> {
  @override
  Future<ClientIdentitySnapshot> build(String clientId) => loadSnapshot(clientId);

  Future<void> refreshSilently() async {
    final previous = state.valueOrNull;
    if (previous != null) {
      state = AsyncValue<ClientIdentitySnapshot>.loading().copyWithPrevious(
        AsyncValue.data(previous),
      );
    } else if (!state.hasValue) {
      state = const AsyncValue.loading();
    }
    try {
      state = AsyncValue.data(await loadSnapshot(arg));
    } catch (error, stackTrace) {
      if (previous != null) {
        state = AsyncValue<ClientIdentitySnapshot>.error(
          error,
          stackTrace,
        ).copyWithPrevious(AsyncValue.data(previous));
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<ClientIdentitySnapshot> loadSnapshot(String clientId) async {
    final isOffice = !ref.read(accountContextProvider).isPersonal;
    if (isOffice) {
      final record = await ref
          .read(officeClientsApiProvider)
          .getClient(clientId);
      return record.toSnapshot();
    }
    final record = await ref.read(clientsRepositoryProvider).getClient(clientId);
    return clientIdentityFromApiRecord(record);
  }
}

void refreshClientIdentity(WidgetRef ref, String clientId) {
  ref.read(clientIdentityProvider(clientId).notifier).refreshSilently();
}