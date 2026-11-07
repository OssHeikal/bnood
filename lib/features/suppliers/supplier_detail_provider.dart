import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/providers/app_providers.dart';
import '../clients/client_movement_lines.dart';
import 'supplier_detail_snapshot.dart';

final supplierSpendTransactionsWatchProvider =
    StreamProvider.family<List<Transaction>, String>((ref, supplierId) {
  return ref.watch(repositoryProvider).watchSupplierSpendTransactions(supplierId);
});

final supplierDetailProvider = AsyncNotifierProvider.family<SupplierDetailNotifier, SupplierDetailSnapshot, String>(
  SupplierDetailNotifier.new,
);

class SupplierDetailNotifier extends FamilyAsyncNotifier<SupplierDetailSnapshot, String> {
  int _reloadSeq = 0;

  @override
  Future<SupplierDetailSnapshot> build(String supplierId) async {
    ref.listen(supplierSpendTransactionsWatchProvider(supplierId), (previous, next) {
      if (previous == null) return;
      next.whenData((_) => refreshSilently());
    });
    return loadSnapshot(supplierId);
  }

  Future<void> refreshSilently() async {
    final previous = state.valueOrNull;
    final seq = ++_reloadSeq;
    if (previous != null) {
      state = AsyncValue<SupplierDetailSnapshot>.loading().copyWithPrevious(AsyncValue.data(previous));
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
        state = AsyncValue<SupplierDetailSnapshot>.error(error, stackTrace).copyWithPrevious(
          AsyncValue.data(previous),
        );
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<SupplierDetailSnapshot> loadSnapshot(String supplierId) async {
    final repo = ref.read(repositoryProvider);
    final supplier = await repo.getSupplier(supplierId);
    if (supplier == null) throw const SupplierDetailNotFound();

    final transactions = await repo.supplierTransactions(supplierId);
    final totalPaid = transactions.fold<int>(0, (sum, t) => sum + t.amountPiastres);

    final items = await repo.watchActiveItems().first;
    final suppliers = await repo.watchActiveSuppliers().first;
    final craftsmen = await repo.watchActiveCraftsmen().first;
    final itemById = {for (final i in items) i.id: i};
    final supplierById = {for (final s in suppliers) s.id: s, supplier.id: supplier};
    final craftsmanById = {for (final c in craftsmen) c.id: c};

    final projectIds = transactions.map((t) => t.projectId).toSet();
    final clientByProject = await repo.clientInfoForProjectIds(projectIds);

    final history = <SupplierDetailHistoryEntry>[];
    for (final t in transactions) {
      final client = clientByProject[t.projectId];
      final line = movementLineFromTransaction(
        t,
        itemById: itemById,
        supplierById: supplierById,
        craftsmanById: craftsmanById,
      );
      history.add(
        SupplierDetailHistoryEntry(
          line: line,
          clientId: client?.clientId ?? '',
          clientName: client?.clientName ?? '—',
        ),
      );
    }

    return SupplierDetailSnapshot(
      supplier: supplier,
      totalPaidPiastres: totalPaid,
      history: history,
    );
  }
}
