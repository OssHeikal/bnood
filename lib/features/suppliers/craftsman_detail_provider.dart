import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/ledger_math.dart';
import '../../core/providers/app_providers.dart';
import '../clients/client_movement_lines.dart';
import 'craftsman_detail_snapshot.dart';

final craftsmanDetailWatchProvider = StreamProvider.family<void, String>((ref, craftsmanId) {
  return ref.watch(repositoryProvider).watchCraftsmanDetailSignals(craftsmanId);
});

final craftsmanDetailProvider =
    AsyncNotifierProvider.family<CraftsmanDetailNotifier, CraftsmanDetailSnapshot, String>(
  CraftsmanDetailNotifier.new,
);

class CraftsmanDetailNotifier extends FamilyAsyncNotifier<CraftsmanDetailSnapshot, String> {
  int _reloadSeq = 0;

  @override
  Future<CraftsmanDetailSnapshot> build(String craftsmanId) async {
    ref.listen(craftsmanDetailWatchProvider(craftsmanId), (previous, next) {
      if (previous == null) return;
      next.whenData((_) => refreshSilently());
    });
    return loadSnapshot(craftsmanId);
  }

  Future<void> refreshSilently() async {
    final previous = state.valueOrNull;
    final seq = ++_reloadSeq;
    if (previous != null) {
      state = AsyncValue<CraftsmanDetailSnapshot>.loading().copyWithPrevious(AsyncValue.data(previous));
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
        state = AsyncValue<CraftsmanDetailSnapshot>.error(error, stackTrace).copyWithPrevious(
          AsyncValue.data(previous),
        );
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<CraftsmanDetailSnapshot> loadSnapshot(String craftsmanId) async {
    final repo = ref.read(repositoryProvider);
    final craftsman = await repo.getCraftsman(craftsmanId);
    if (craftsman == null) throw const CraftsmanDetailNotFound();

    final agreements = await repo.agreementsForCraftsman(craftsmanId);
    final laborTransactions = await repo.craftsmanLaborTransactions(craftsmanId);
    final totalLaborPaid = laborTransactions.fold<int>(0, (sum, t) => sum + t.amountPiastres);

    final projectIds = {
      ...agreements.map((a) => a.projectId),
      ...laborTransactions.map((t) => t.projectId),
    };
    final clientByProject = await repo.clientInfoForProjectIds(projectIds);

    final items = await repo.watchActiveItems().first;
    final suppliers = await repo.watchActiveSuppliers().first;
    final craftsmen = await repo.watchActiveCraftsmen().first;
    final itemById = {for (final i in items) i.id: i};
    final supplierById = {for (final s in suppliers) s.id: s};
    final craftsmanById = {for (final c in craftsmen) c.id: c, craftsman.id: craftsman};

    final jobs = <CraftsmanDetailJobRow>[];
    for (final agreement in agreements) {
      final client = clientByProject[agreement.projectId];
      final tx = await repo.transactionsForProject(agreement.projectId);
      final paid = LedgerMath.craftsmanPaidPiastres(rows: tx, craftsmanId: craftsmanId);
      final remaining = LedgerMath.craftsmanRemainingPiastres(
        initialAmountPiastres: agreement.initialAmountPiastres,
        paidPiastres: paid,
      );
      jobs.add(
        CraftsmanDetailJobRow(
          projectId: agreement.projectId,
          clientId: client?.clientId ?? '',
          clientName: client?.clientName ?? '—',
          paidPiastres: paid,
          agreedPiastres: agreement.initialAmountPiastres,
          remainingPiastres: remaining,
        ),
      );
    }
    jobs.sort((a, b) => a.clientName.compareTo(b.clientName));

    final history = <CraftsmanDetailHistoryEntry>[];
    for (final t in laborTransactions) {
      final client = clientByProject[t.projectId];
      history.add(
        CraftsmanDetailHistoryEntry(
          line: movementLineFromTransaction(
            t,
            itemById: itemById,
            supplierById: supplierById,
            craftsmanById: craftsmanById,
          ),
          clientId: client?.clientId ?? '',
          clientName: client?.clientName ?? '—',
        ),
      );
    }

    return CraftsmanDetailSnapshot(
      craftsman: craftsman,
      totalLaborPaidPiastres: totalLaborPaid,
      linkedProjectCount: agreements.length,
      jobs: jobs,
      history: history,
    );
  }
}
