import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/clients/presentation/models/client_detail_snapshot.dart';
import 'package:bnood/features/projects/presentation/providers/project_detail_loader.dart';
import 'package:bnood/features/projects/presentation/providers/project_detail_provider.dart';

/// Ledger detail for the client's primary project (legacy client-id routes).
final clientDetailProvider =
    AsyncNotifierProvider.family<
      ClientDetailNotifier,
      ClientDetailSnapshot,
      String
    >(ClientDetailNotifier.new);

class ClientDetailNotifier
    extends FamilyAsyncNotifier<ClientDetailSnapshot, String> {
  int _reloadSeq = 0;

  @override
  Future<ClientDetailSnapshot> build(String arg) async {
    final params = await primaryProjectParamsForClient(ref, arg);
    return loadProjectDetailSnapshot(ref, params);
  }

  Future<void> refreshSilently() async {
    final previous = state.valueOrNull;
    final seq = ++_reloadSeq;
    if (previous != null) {
      state = AsyncValue<ClientDetailSnapshot>.loading().copyWithPrevious(
        AsyncValue.data(previous),
      );
    } else if (!state.hasValue) {
      state = const AsyncValue.loading();
    }
    try {
      final params = await primaryProjectParamsForClient(ref, arg);
      final next = await loadProjectDetailSnapshot(ref, params);
      if (seq != _reloadSeq) return;
      state = AsyncValue.data(next);
    } catch (error, stackTrace) {
      if (seq != _reloadSeq) return;
      if (previous != null) {
        state = AsyncValue<ClientDetailSnapshot>.error(
          error,
          stackTrace,
        ).copyWithPrevious(AsyncValue.data(previous));
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }
}

void refreshClientDetail(WidgetRef ref, String clientId) {
  ref.read(clientDetailProvider(clientId).notifier).refreshSilently();
}