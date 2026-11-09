import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/agreements/agreements_riverpod.dart';
import '../../core/clients/clients_providers.dart';
import '../../core/money/ledger_math.dart';
import '../../core/money/money_format.dart';
import '../../core/providers/app_providers.dart';
import '../../core/vouchers/vouchers_riverpod.dart';
import 'client_detail_snapshot.dart';
import 'client_movement_lines.dart';
import 'client_voucher_movement_lines.dart';
import 'widgets/client_balance_card.dart';

final clientDetailProvider =
    AsyncNotifierProvider.family<ClientDetailNotifier, ClientDetailSnapshot, String>(
  ClientDetailNotifier.new,
);

class ClientDetailNotifier extends FamilyAsyncNotifier<ClientDetailSnapshot, String> {
  int _reloadSeq = 0;

  @override
  Future<ClientDetailSnapshot> build(String arg) => loadSnapshot(arg);

  Future<void> refreshSilently() async {
    final previous = state.valueOrNull;
    final seq = ++_reloadSeq;
    if (previous != null) {
      state = AsyncValue<ClientDetailSnapshot>.loading().copyWithPrevious(AsyncValue.data(previous));
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
        state = AsyncValue<ClientDetailSnapshot>.error(error, stackTrace).copyWithPrevious(
          AsyncValue.data(previous),
        );
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<ClientDetailSnapshot> loadSnapshot(String clientId) async {
    if (ref.read(remoteClientsEnabledProvider)) {
      return _loadRemoteSnapshot(clientId);
    }
    return _loadLocalSnapshot(clientId);
  }

  Future<ClientDetailSnapshot> _loadRemoteSnapshot(String clientId) async {
    final record = await ref.read(clientsRepositoryProvider).getClient(clientId);
    final balances = record.balances;
    var previews = <ClientCraftsmanPreviewRow>[];
    if (ref.read(remoteAgreementsEnabledProvider)) {
      final agreements = await ref.read(appAgreementsRepositoryProvider).listAllClientAgreements(clientId);
      previews = agreements
          .map(
            (a) => ClientCraftsmanPreviewRow(
              craftsmanId: a.providerId,
              name: a.providerName ?? '—',
              trade: null,
              paidPiastres: a.paidMinorForDisplay,
              agreedPiastres: a.amountMinorForDisplay,
              remainingPiastres: a.remainingMinorForDisplay,
              accentKey: clientAccentKeyFor(a.providerId),
              agreementId: a.id,
              onlineAgreementsOnly: true,
              usesRemoteMoney: true,
            ),
          )
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    }

    var latestMovements = <ClientDetailMovementLine>[];
    final vouchersOnline = ref.read(remoteVouchersEnabledProvider);
    if (vouchersOnline) {
      final vouchers = await ref.read(vouchersRepositoryProvider).listClientVouchers(
            clientId: clientId,
            page: 1,
            perPage: 5,
          );
      latestMovements = movementLinesFromVouchers(
        vouchers.items,
        projectId: record.project.id,
      );
    }

    return ClientDetailSnapshot(
      client: record.client,
      project: record.project,
      receivedPiastres: balances?.receivedPiastres,
      spentPiastres: balances?.spentPiastres,
      estimatedProfitPiastres: null,
      craftsmanPreviews: previews,
      topItems: const [],
      latestMovements: latestMovements,
      onlineIdentityOnly: !vouchersOnline,
      usesRemoteMoney: true,
      remainingFromServer: balances?.remainingPiastres,
    );
  }

  Future<ClientDetailSnapshot> _loadLocalSnapshot(String clientId) async {
    final repo = ref.read(repositoryProvider);
    final client = await repo.getClient(clientId);
    final project = await repo.primaryProjectForClient(clientId);
    if (project == null) throw StateError('Project missing');
    final tx = await repo.transactionsForProject(project.id);
    final balance = LedgerMath.projectBalance(tx);
    final profit = project.engineerBasisPoints == null
        ? null
        : MoneyFormat.estimatedProfitPiastres(
            totalSpendPiastres: balance.spentPiastres,
            engineerBasisPoints: project.engineerBasisPoints!,
          );
    final agreements = await repo.agreementsForProject(project.id);
    final craftsmen = await repo.watchActiveCraftsmen().first;
    final suppliers = await repo.watchActiveSuppliers().first;
    final items = await repo.watchActiveItems().first;
    final itemById = {for (final i in items) i.id: i};
    final supplierById = {for (final s in suppliers) s.id: s};
    final craftsmanById = {for (final c in craftsmen) c.id: c};

    final previews = <ClientCraftsmanPreviewRow>[];
    for (final a in agreements.take(3)) {
      final c = craftsmanById[a.craftsmanId];
      if (c == null) continue;
      final paid = LedgerMath.craftsmanPaidPiastres(rows: tx, craftsmanId: a.craftsmanId);
      previews.add(
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

    final spend = tx.where((t) => t.kind == 'spend').toList();
    final breakdown = LedgerMath.itemBreakdown(spend);
    final topItems = breakdown.entries.toList()..sort((a, b) => b.value.totalPiastres.compareTo(a.value.totalPiastres));
    final topItemsNamed = topItems.take(3).map((e) {
      final item = itemById[e.key];
      return ClientDetailItemRowData(
        name: item?.name ?? e.key,
        colorKey: item?.colorKey ?? 'teal',
        iconName: item?.iconName ?? 'category',
        breakdown: e.value,
      );
    }).toList();

    final latest = [...tx]..sort((a, b) => b.date.compareTo(a.date));
    final movementLines = movementLinesFromTransactions(
      latest.take(5).toList(),
      itemById: itemById,
      supplierById: supplierById,
      craftsmanById: craftsmanById,
    );

    return ClientDetailSnapshot(
      client: client,
      project: project,
      receivedPiastres: balance.receivedPiastres,
      spentPiastres: balance.spentPiastres,
      estimatedProfitPiastres: profit,
      craftsmanPreviews: previews,
      topItems: topItemsNamed,
      latestMovements: movementLines,
    );
  }
}

void refreshClientDetail(WidgetRef ref, String clientId) {
  ref.read(clientDetailProvider(clientId).notifier).refreshSilently();
}
