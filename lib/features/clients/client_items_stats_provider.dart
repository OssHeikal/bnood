import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clients/clients_providers.dart';
import '../../core/money/ledger_math.dart';
import '../../core/providers/app_providers.dart';
import 'client_detail_snapshot.dart';
import 'client_item_spend_rows.dart';

final clientItemsStatsProvider =
    AsyncNotifierProvider.family<ClientItemsStatsNotifier, List<ClientDetailItemRowData>, String>(
  ClientItemsStatsNotifier.new,
);

class ClientItemsStatsNotifier extends FamilyAsyncNotifier<List<ClientDetailItemRowData>, String> {
  int _reloadSeq = 0;

  @override
  Future<List<ClientDetailItemRowData>> build(String arg) => loadSnapshot(arg);

  Future<void> refreshSilently() async {
    final previous = state.valueOrNull;
    final seq = ++_reloadSeq;
    if (previous != null) {
      state = AsyncValue<List<ClientDetailItemRowData>>.loading().copyWithPrevious(AsyncValue.data(previous));
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
        state = AsyncValue<List<ClientDetailItemRowData>>.error(error, stackTrace).copyWithPrevious(
          AsyncValue.data(previous),
        );
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<List<ClientDetailItemRowData>> loadSnapshot(String clientId) async {
    if (ref.read(remoteClientsEnabledProvider)) {
      final spend = await ref.read(clientsRepositoryProvider).getClientItemSpend(clientId);
      return clientItemRowsFromItemSpend(spend.items);
    }
    final repo = ref.read(repositoryProvider);
    final project = await repo.primaryActiveProject(clientId);
    if (project == null) return [];
    final tx = await repo.transactionsForProject(project.id);
    final spend = tx.where((t) => t.kind == 'spend').toList();
    final breakdown = LedgerMath.itemBreakdown(spend);
    final items = await repo.watchActiveItems().first;
    final itemById = {for (final i in items) i.id: i};
    final rows = breakdown.entries.toList()..sort((a, b) => b.value.totalPiastres.compareTo(a.value.totalPiastres));
    return rows
        .map((e) {
          final item = itemById[e.key];
          return ClientDetailItemRowData(
            itemId: e.key,
            name: item?.name ?? e.key,
            colorKey: item?.colorKey ?? 'teal',
            iconName: item?.iconName ?? 'layers',
            breakdown: e.value,
          );
        })
        .toList();
  }
}
