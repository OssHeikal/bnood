import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/agreements/agreements_riverpod.dart';
import '../../core/clients/client_provider_agreement_preview.dart';
import '../../core/clients/clients_providers.dart';
import '../../core/providers_api/app_provider_record.dart';
import '../../core/money/ledger_math.dart';
import '../../core/providers/app_providers.dart';
import 'client_detail_snapshot.dart';
import 'widgets/client_balance_card.dart';

final clientProjectCraftsmenWatchProvider =
    StreamProvider.family<void, String>((ref, projectId) {
  return ref.watch(repositoryProvider).watchProjectCraftsmenSignals(projectId);
});

final clientCraftsmenListProvider =
    AsyncNotifierProvider.family<ClientCraftsmenListNotifier, ClientCraftsmenListSnapshot, String>(
  ClientCraftsmenListNotifier.new,
);

class ClientCraftsmenListSnapshot {
  const ClientCraftsmenListSnapshot({
    required this.projectId,
    required this.rows,
    this.clientName,
  });

  final String? projectId;
  final List<ClientCraftsmanPreviewRow> rows;
  final String? clientName;
}

class ClientCraftsmenListNotifier extends FamilyAsyncNotifier<ClientCraftsmenListSnapshot, String> {
  int _reloadSeq = 0;

  @override
  Future<ClientCraftsmenListSnapshot> build(String clientId) async {
    final snap = await loadSnapshot(clientId);
    final projectId = snap.projectId;
    if (projectId != null) {
      ref.listen(clientProjectCraftsmenWatchProvider(projectId), (previous, next) {
        if (previous == null) return;
        next.whenData((_) => refreshSilently());
      });
    }
    return snap;
  }

  Future<void> refreshSilently() async {
    final previous = state.valueOrNull;
    final seq = ++_reloadSeq;
    if (previous != null) {
      state = AsyncValue<ClientCraftsmenListSnapshot>.loading().copyWithPrevious(AsyncValue.data(previous));
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
        state = AsyncValue<ClientCraftsmenListSnapshot>.error(error, stackTrace).copyWithPrevious(
          AsyncValue.data(previous),
        );
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<ClientCraftsmenListSnapshot> loadSnapshot(String clientId) async {
    if (ref.read(remoteClientsEnabledProvider)) {
      return _loadRemoteSnapshot(clientId);
    }
    final repo = ref.read(repositoryProvider);
    final project = await repo.primaryActiveProject(clientId);
    if (project == null) {
      return const ClientCraftsmenListSnapshot(projectId: null, rows: []);
    }
    final agreements = await repo.agreementsForProject(project.id);
    final tx = await repo.transactionsForProject(project.id);
    final craftsmen = await repo.listActiveCraftsmen();
    final byId = {for (final c in craftsmen) c.id: c};

    final rows = <ClientCraftsmanPreviewRow>[];
    for (final a in agreements) {
      final c = byId[a.craftsmanId];
      if (c == null) continue;
      final paid = LedgerMath.craftsmanPaidPiastres(rows: tx, craftsmanId: c.id);
      rows.add(
        ClientCraftsmanPreviewRow(
          craftsmanId: c.id,
          name: c.name,
          trade: c.trade,
          paidPiastres: paid,
          agreedPiastres: a.initialAmountPiastres,
          remainingPiastres: LedgerMath.craftsmanRemainingPiastres(
            initialAmountPiastres: a.initialAmountPiastres,
            paidPiastres: paid,
          ),
          accentKey: clientAccentKeyFor(c.id),
        ),
      );
    }
    rows.sort((a, b) => a.name.compareTo(b.name));
    return ClientCraftsmenListSnapshot(projectId: project.id, rows: rows);
  }

  Future<ClientCraftsmenListSnapshot> _loadRemoteSnapshot(String clientId) async {
    final record = await ref.read(clientsRepositoryProvider).getClient(clientId);
    final agreements = await ref.read(appAgreementsRepositoryProvider).listAllClientAgreements(clientId);
    final rows = clientAgreementPreviews(agreements, AppProviderType.craftsman);
    return ClientCraftsmenListSnapshot(
      projectId: record.project.id,
      clientName: record.client.name,
      rows: rows,
    );
  }
}
