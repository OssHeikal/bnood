import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../clients/clients_providers.dart';
import '../clients/clients_repository.dart';
import '../home/home_dashboard_mapping.dart';
import '../home/home_riverpod.dart';
import '../home/home_section_counts.dart';
import '../database/database.dart';
import '../repositories/bnood_repository.dart';
import '../../features/clients/client_craftsmen_list_provider.dart';
import '../../features/clients/client_detail_provider.dart';
import '../../features/clients/client_items_stats_provider.dart';
import '../../features/clients/client_suppliers_list_provider.dart';
import '../../features/providers/provider_detail_provider.dart';
import '../shared/pagination/paging_refresh.dart';
import '../subscription/subscription_riverpod.dart';
import 'app_providers.dart';
import 'silent_async_notifier.dart';

final homeTotalsProvider = AsyncNotifierProvider<HomeTotalsNotifier, HomeTotals>(HomeTotalsNotifier.new);

final activeClientsProvider = FutureProvider((ref) {
  return ref.watch(repositoryProvider).watchActiveClients();
});

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

/// Silent reload of home sections. The future completes when those sections finish.
Future<void> refreshHomeDashboard(WidgetRef ref) {
  if (ref.read(remoteClientsEnabledProvider)) {
    ref.read(homeRepositoryProvider).invalidateDashboard();
  }
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

/// After client create/update/archive — keeps Home, Clients list, and optional detail in sync (silent).
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
  final remoteClients = ref.read(remoteClientsEnabledProvider);
  if (remoteClients) {
    ref.read(homeRepositoryProvider).invalidateDashboard();
    bumpPagingListRefresh(ref, PagingListIds.clients);
    ref.read(homeTotalsProvider.notifier).refreshSilently();
    ref.read(homeClientBalancesProvider.notifier).refreshSilently();
    ref.read(homeCraftsmenProvider.notifier).refreshSilently();
    ref.read(subscriptionProvider.notifier).refreshSilently();
  } else {
    refreshHomeDashboard(ref);
  }
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
    if (ref.read(remoteClientsEnabledProvider)) {
      final remote = await ref.read(homeRepositoryProvider).getHomeTotals();
      return HomeTotals(
        receivedPiastres: remote.receivedMinor,
        spentPiastres: remote.spentMinor,
        remainingPiastresOverride: remote.remainingMinor,
      );
    }
    return ref.read(repositoryProvider).homeTotals();
  }
}

Future<List<HomeClientBalanceRow>> homeClientBalanceRows(
  BnoodRepository repo,
  List<Client> clients, {
  required bool activeProjectsOnly,
}) async {
  final rows = <HomeClientBalanceRow>[];
  for (final client in clients) {
    final project = activeProjectsOnly
        ? await repo.primaryActiveProject(client.id)
        : await repo.primaryProjectForClient(client.id);
    if (project == null) {
      rows.add(
        HomeClientBalanceRow(
          client: client,
          remainingPiastres: 0,
          receivedPiastres: 0,
          spentPiastres: 0,
        ),
      );
      continue;
    }
    final balance = await repo.projectBalance(project.id);
    rows.add(
      HomeClientBalanceRow(
        client: client,
        remainingPiastres: balance.balancePiastres,
        receivedPiastres: balance.receivedPiastres,
        spentPiastres: balance.spentPiastres,
      ),
    );
  }
  return rows;
}

class HomeClientBalancesNotifier extends SilentAsyncNotifier<List<HomeClientBalanceRow>> {
  @override
  Future<List<HomeClientBalanceRow>> fetch() async {
    if (ref.read(remoteClientsEnabledProvider)) {
      final dashboard = await ref.read(homeRepositoryProvider).getHomeDashboard();
      return dashboard.clients.map(homeClientBalanceRowFromPreview).toList();
    }
    final repo = ref.read(repositoryProvider);
    final clients = await repo.watchActiveClients();
    return homeClientBalanceRows(repo, clients, activeProjectsOnly: true);
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
    if (!ref.read(remoteClientsEnabledProvider)) return;
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
    if (ref.read(remoteClientsEnabledProvider)) {
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
    final repo = ref.read(repositoryProvider);
    final filter = ref.read(clientsListFilterProvider);
    final clients = await repo.listClients(filter);
    final rows = await homeClientBalanceRows(repo, clients, activeProjectsOnly: false);
    return ClientsListSnapshot(rows: rows, page: 1, total: rows.length, hasMore: false);
  }
}

class HomeSupplierSpendsNotifier extends SilentAsyncNotifier<List<HomeSupplierSpendRow>> {
  @override
  Future<List<HomeSupplierSpendRow>> fetch() async {
    if (ref.read(remoteClientsEnabledProvider)) {
      return const [];
    }
    return ref.read(repositoryProvider).homeSupplierSpendsForActiveClients();
  }
}

class HomeCraftsmenNotifier extends SilentAsyncNotifier<List<HomeCraftsmanActivityRow>> {
  @override
  Future<List<HomeCraftsmanActivityRow>> fetch() async {
    if (ref.read(remoteClientsEnabledProvider)) {
      final dashboard = await ref.read(homeRepositoryProvider).getHomeDashboard();
      ref.read(homeSectionCountsProvider.notifier).state = HomeSectionCounts(
        clientsCount: dashboard.clientsCount ?? dashboard.clients.length,
        craftsmenCount: dashboard.craftsmenCount ?? dashboard.craftsmen.length,
        suppliersCount: dashboard.suppliersCount ?? dashboard.suppliers.length,
      );
      return dashboard.craftsmen.map(homeCraftsmanRowFromPreview).toList();
    }
    return ref.read(repositoryProvider).homeCraftsmenByRecentLabor();
  }
}

class HomeSuppliersNotifier extends SilentAsyncNotifier<List<HomeCraftsmanActivityRow>> {
  @override
  Future<List<HomeCraftsmanActivityRow>> fetch() async {
    if (ref.read(remoteClientsEnabledProvider)) {
      final dashboard = await ref.read(homeRepositoryProvider).getHomeDashboard();
      return dashboard.suppliers.map(homeCraftsmanRowFromPreview).toList();
    }
    return const [];
  }
}
