import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/agreements/agreements_riverpod.dart';
import '../../core/clients/client_provider_agreement_preview.dart';
import '../../core/clients/clients_providers.dart';
import '../../core/providers_api/app_provider_record.dart';
import 'client_detail_snapshot.dart';

final clientSuppliersListProvider =
    AsyncNotifierProvider.family<ClientSuppliersListNotifier, ClientSuppliersListSnapshot, String>(
  ClientSuppliersListNotifier.new,
);

class ClientSuppliersListSnapshot {
  const ClientSuppliersListSnapshot({
    required this.projectId,
    required this.rows,
    this.clientName,
  });

  final String? projectId;
  final List<ClientCraftsmanPreviewRow> rows;
  final String? clientName;
}

class ClientSuppliersListNotifier extends FamilyAsyncNotifier<ClientSuppliersListSnapshot, String> {
  int _reloadSeq = 0;

  @override
  Future<ClientSuppliersListSnapshot> build(String clientId) => loadSnapshot(clientId);

  Future<void> refreshSilently() async {
    final previous = state.valueOrNull;
    final seq = ++_reloadSeq;
    if (previous != null) {
      state = AsyncValue<ClientSuppliersListSnapshot>.loading().copyWithPrevious(AsyncValue.data(previous));
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
        state = AsyncValue<ClientSuppliersListSnapshot>.error(error, stackTrace).copyWithPrevious(
          AsyncValue.data(previous),
        );
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<ClientSuppliersListSnapshot> loadSnapshot(String clientId) async {
    if (ref.read(remoteClientsEnabledProvider)) {
      return _loadRemoteSnapshot(clientId);
    }
    return const ClientSuppliersListSnapshot(projectId: null, rows: []);
  }

  Future<ClientSuppliersListSnapshot> _loadRemoteSnapshot(String clientId) async {
    final record = await ref.read(clientsRepositoryProvider).getClient(clientId);
    final agreements = await ref.read(appAgreementsRepositoryProvider).listAllClientAgreements(clientId);
    final rows = clientAgreementPreviews(agreements, AppProviderType.supplier);
    return ClientSuppliersListSnapshot(
      projectId: record.project.id,
      clientName: record.client.name,
      rows: rows,
    );
  }
}
