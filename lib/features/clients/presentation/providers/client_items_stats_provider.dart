import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/clients/data/clients_providers.dart';
import 'package:bnood/features/clients/presentation/models/client_detail_snapshot.dart';
import 'package:bnood/features/clients/presentation/models/client_item_spend_rows.dart';

final clientItemsStatsProvider =
    AsyncNotifierProvider.family<
      ClientItemsStatsNotifier,
      List<ClientDetailItemRowData>,
      String
    >(ClientItemsStatsNotifier.new);

class ClientItemsStatsNotifier
    extends FamilyAsyncNotifier<List<ClientDetailItemRowData>, String> {
  int _reloadSeq = 0;

  @override
  Future<List<ClientDetailItemRowData>> build(String arg) => loadSnapshot(arg);

  Future<void> refreshSilently() async {
    final previous = state.valueOrNull;
    final seq = ++_reloadSeq;
    if (previous != null) {
      state = AsyncValue<List<ClientDetailItemRowData>>.loading()
          .copyWithPrevious(AsyncValue.data(previous));
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
        state = AsyncValue<List<ClientDetailItemRowData>>.error(
          error,
          stackTrace,
        ).copyWithPrevious(AsyncValue.data(previous));
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<List<ClientDetailItemRowData>> loadSnapshot(String clientId) async {
    final spend = await ref
        .read(clientsRepositoryProvider)
        .getClientItemSpend(clientId);
    return clientItemRowsFromItemSpend(spend.items);
  }
}
