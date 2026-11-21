import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/clients/data/client_list_archive_filter.dart';
import '../../features/clients/data/clients_providers.dart';
import '../../features/clients/data/clients_repository.dart';
import '../home/home_dashboard_mapping.dart';
import '../home/home_riverpod.dart';
import '../home/home_row_models.dart';
import '../home/home_section_counts.dart';
import '../../features/clients/presentation/client_craftsmen_list_provider.dart';
import '../../features/clients/presentation/client_detail_provider.dart';
import '../../features/clients/presentation/client_items_stats_provider.dart';
import '../../features/clients/presentation/client_suppliers_list_provider.dart';
import '../../features/providers/presentation/provider_detail_provider.dart';
import '../shared/pagination/paging_refresh.dart';
import '../subscription/subscription_riverpod.dart';
import 'silent_async_notifier.dart';

final homeTotalsProvider = AsyncNotifierProvider<HomeTotalsNotifier, HomeTotals>(HomeTotalsNotifier.new);

final homeClientBalancesProvider =
    AsyncNotifierProvider<HomeClientBalancesNotifier, List<HomeClientBalanceRow>>(
  HomeClientBalancesNotifier.new,
);

final clientsListFilterProvider =
    StateProvider<ClientListArchiveFilter>((ref) => ClientListArchiveFilter.active);

final clientsListSearchQueryProvider = StateProvider<String>((ref) => '');

class ClientsListSnapshot {
  const ClientsListSnapshot({
    required this.rows,
    required this.page,
    required this.total,
    required this.hasMore,
  });

  final List<HomeClientBalanceRow> rows;
  final int page;
  final int total;
  final bool hasMore;
}

final clientsListProvider =
    AsyncNotifierProvider<ClientsListNotifier, ClientsListSnapshot>(ClientsListNotifier.new);

final clientsListBalancesProvider = clientsListProvider;

final homeSupplierSpendsProvider =
    AsyncNotifierProvider<HomeSupplierSpendsNotifier, List<HomeSupplierSpendRow>>(
  HomeSupplierSpendsNotifier.new,
);

final homeCraftsmenProvider =
    AsyncNotifierProvider<HomeCraftsmenNotifier, List<HomeCraftsmanActivityRow>>(
  HomeCraftsmenNotifier.new,
);

final homeSuppliersProvider =
    AsyncNotifierProvider<HomeSuppliersNotifier, List<HomeCraftsmanActivityRow>>(
  HomeSuppliersNotifier.new,
);

Future<void> refreshHomeDashboard(WidgetRef ref) {
  ref.read(homeRepositoryProvider).invalidateDashboard();
  final pending = Future.wait([
    ref.read(homeTotalsProvider.notifier).refreshSilently(),
    ref.read(homeClientBalancesProvider.notifier).refreshSilently(),
    ref.read(homeSupplierSpendsProvider.notifier).refreshSilently(),
    ref.read(homeCraftsmenProvider.notifier).refreshSilently(),
    ref.read(homeSuppliersProvider.notifier).refreshSilently(),
  ]);
  bumpPagingListRefresh(ref, PagingListIds.clients);
  return pending;
}

void refreshAfterProviderClientAssignments(
  WidgetRef ref, {
  required String providerId,
  required Iterable<String> affectedClientIds,
}) {
  ref.read(providerDetailProvider(providerId).notifier).refreshSilently();
  for (final clientId in affectedClientIds.toSet()) {
    refreshAfterClientMutation(ref, clientId: clientId);
    ref.invalidate(clientCraftsmenListProvider(clientId));
    ref.invalidate(clientSuppliersListProvider(clientId));
  }
}

void refreshAfterClientMutation(WidgetRef ref, {String? clientId, String? priorClientId}) {
  ref.read(homeRepositoryProvider).invalidateDashboard();
  bumpPagingListRefresh(ref, PagingListIds.clients);
  ref.read(homeTotalsProvider.notifier).refreshSilently();
  ref.read(homeClientBalancesProvider.notifier).refreshSilently();
  ref.read(homeCraftsmenProvider.notifier).refreshSilently();
  ref.read(subscriptionProvider.notifier).refreshSilently();
  final ids = <String>{};
  if (clientId != null) ids.add(clientId);
  if (priorClientId != null) ids.add(priorClientId);
  for (final id in ids) {
    refreshClientDetail(ref, id);
    ref.read(clientItemsStatsProvider(id).notifier).refreshSilently();
  }
}

class HomeTotalsNotifier extends SilentAsyncNotifier<HomeTotals> {
  @override
  Future<HomeTotals> fetch() async {
    final remote = await ref.read(homeRepositoryProvider).getHomeTotals();
    return HomeTotals(
      receivedPiastres: remote.receivedMinor,
      spentPiastres: remote.spentMinor,
      remainingPiastresOverride: remote.remainingMinor,
    );
  }
}

class HomeClientBalancesNotifier extends SilentAsyncNotifier<List<HomeClientBalanceRow>> {
  @override
  Future<List<HomeClientBalanceRow>> fetch() async {
    final dashboard = await ref.read(homeRepositoryProvider).getHomeDashboard();
    return dashboard.clients.map(homeClientBalanceRowFromPreview).toList();
  }
}

class ClientsListNotifier extends SilentAsyncNotifier<ClientsListSnapshot> {
  var _loadingMore = false;

  bool get isLoadingMore => _loadingMore;

  @override
  Future<ClientsListSnapshot> build() async {
    ref.watch(clientsListFilterProvider);
    ref.watch(clientsListSearchQueryProvider);
    return fetch();
  }

  @override
  Future<ClientsListSnapshot> fetch() => _fetchPage(page: 1);

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || _loadingMore) return;
    _loadingMore = true;
    final previous = current;
    state = AsyncValue<ClientsListSnapshot>.loading().copyWithPrevious(AsyncValue.data(previous));
    try {
      final next = await _fetchPage(page: current.page + 1, existing: current);
      state = AsyncValue.data(next);
    } catch (error, stackTrace) {
      state = AsyncValue<ClientsListSnapshot>.error(error, stackTrace)
          .copyWithPrevious(AsyncValue.data(previous));
    } finally {
      _loadingMore = false;
    }
  }

  Future<ClientsListSnapshot> _fetchPage({
    required int page,
    ClientsListSnapshot? existing,
  }) async {
    final clientsRepo = ref.read(clientsRepositoryProvider);
    final filter = ref.read(clientsListFilterProvider);
    final q = ref.read(clientsListSearchQueryProvider);
    final result = await clientsRepo.listClients(status: filter, q: q, page: page);
    final rows = result.items.map(balanceRowFromRecord).toList();
    if (existing != null && page > 1) {
      return ClientsListSnapshot(
        rows: [...existing.rows, ...rows],
        page: result.page,
        total: result.total,
        hasMore: result.hasMore,
      );
    }
    return ClientsListSnapshot(
      rows: rows,
      page: result.page,
      total: result.total,
      hasMore: result.hasMore,
    );
  }
}

class HomeSupplierSpendsNotifier extends SilentAsyncNotifier<List<HomeSupplierSpendRow>> {
  @override
  Future<List<HomeSupplierSpendRow>> fetch() async => const [];
}

class HomeCraftsmenNotifier extends SilentAsyncNotifier<List<HomeCraftsmanActivityRow>> {
  @override
  Future<List<HomeCraftsmanActivityRow>> fetch() async {
    final dashboard = await ref.read(homeRepositoryProvider).getHomeDashboard();
    ref.read(homeSectionCountsProvider.notifier).state = HomeSectionCounts(
      clientsCount: dashboard.clientsCount ?? dashboard.clients.length,
      craftsmenCount: dashboard.craftsmenCount ?? dashboard.craftsmen.length,
      suppliersCount: dashboard.suppliersCount ?? dashboard.suppliers.length,
    );
    return dashboard.craftsmen.map(homeCraftsmanRowFromPreview).toList();
  }
}

class HomeSuppliersNotifier extends SilentAsyncNotifier<List<HomeCraftsmanActivityRow>> {
  @override
  Future<List<HomeCraftsmanActivityRow>> fetch() async {
    final dashboard = await ref.read(homeRepositoryProvider).getHomeDashboard();
    return dashboard.suppliers.map(homeCraftsmanRowFromPreview).toList();
  }
}