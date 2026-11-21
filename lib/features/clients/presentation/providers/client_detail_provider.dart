import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/providers/data/agreements_riverpod.dart';
import 'package:bnood/features/clients/data/client_provider_agreement_preview.dart';
import 'package:bnood/features/home/data/craftsman_snapshot_limit.dart';
import 'package:bnood/features/clients/data/clients_providers.dart';
import 'package:bnood/features/providers/data/app_provider_record.dart';
import '../../../../core/domain/money/money_format.dart';
import 'package:bnood/features/vouchers/data/vouchers_riverpod.dart';
import 'package:bnood/features/clients/presentation/models/client_detail_snapshot.dart';
import 'package:bnood/features/clients/presentation/models/client_item_spend_rows.dart';
import 'package:bnood/features/clients/presentation/models/client_voucher_movement_lines.dart';

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
  Future<ClientDetailSnapshot> build(String arg) => loadSnapshot(arg);

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
      final next = await loadSnapshot(arg);
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

  Future<ClientDetailSnapshot> loadSnapshot(String clientId) async {
    final record = await ref
        .read(clientsRepositoryProvider)
        .getClient(clientId);
    final balances = record.balances;
    final agreements = await ref
        .read(appAgreementsRepositoryProvider)
        .listAllClientAgreements(clientId);
    final craftsmanPreviews = craftsmanSnapshotRows(
      clientAgreementPreviews(agreements, AppProviderType.craftsman),
    );
    final supplierPreviews = craftsmanSnapshotRows(
      clientAgreementPreviews(agreements, AppProviderType.supplier),
    );
    final craftsmenCount = record.craftsmenCount ?? craftsmanPreviews.length;
    final suppliersCount = record.suppliersCount ?? supplierPreviews.length;

    final itemSpend = await ref
        .read(clientsRepositoryProvider)
        .getClientItemSpend(clientId);
    final itemsCount = itemSpend.items.length;
    final topItems = clientItemRowsFromItemSpend(itemSpend.items.take(3));

    final vouchers = await ref
        .read(vouchersRepositoryProvider)
        .listClientVouchers(clientId: clientId, page: 1, perPage: 5);
    final latestMovements = movementLinesFromVouchers(
      vouchers.items,
      projectId: record.project.id,
    );

    final spentMinor = balances?.spentPiastres;
    final profit =
        record.project.engineerBasisPoints == null || spentMinor == null
        ? null
        : MoneyFormat.estimatedProfitPiastres(
            totalSpendPiastres: spentMinor,
            engineerBasisPoints: record.project.engineerBasisPoints!,
          );

    return ClientDetailSnapshot(
      client: record.client,
      project: record.project,
      receivedPiastres: balances?.receivedPiastres,
      spentPiastres: spentMinor,
      estimatedProfitPiastres: profit,
      craftsmanPreviews: craftsmanPreviews,
      supplierPreviews: supplierPreviews,
      craftsmenCount: craftsmenCount,
      suppliersCount: suppliersCount,
      itemsCount: itemsCount,
      movementsCount: vouchers.total,
      topItems: topItems,
      latestMovements: latestMovements,
      onlineIdentityOnly: false,
      usesRemoteMoney: true,
      remainingFromServer: balances?.remainingPiastres,
    );
  }
}

void refreshClientDetail(WidgetRef ref, String clientId) {
  ref.read(clientDetailProvider(clientId).notifier).refreshSilently();
}
