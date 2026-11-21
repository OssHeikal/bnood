import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/clients/data/client_list_archive_filter.dart';
import 'package:bnood/features/clients/data/clients_providers.dart';
import 'package:bnood/features/clients/data/clients_repository.dart';
import 'package:bnood/features/home/data/home_row_models.dart';
import '../../../../core/app_state/silent_async_notifier.dart';

final clientsListFilterProvider = StateProvider<ClientListArchiveFilter>(
  (ref) => ClientListArchiveFilter.active,
);

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
    AsyncNotifierProvider<ClientsListNotifier, ClientsListSnapshot>(
      ClientsListNotifier.new,
    );

final clientsListBalancesProvider = clientsListProvider;

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
    state = AsyncValue<ClientsListSnapshot>.loading().copyWithPrevious(
      AsyncValue.data(previous),
    );
    try {
      final next = await _fetchPage(page: current.page + 1, existing: current);
      state = AsyncValue.data(next);
    } catch (error, stackTrace) {
      state = AsyncValue<ClientsListSnapshot>.error(
        error,
        stackTrace,
      ).copyWithPrevious(AsyncValue.data(previous));
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
    final result = await clientsRepo.listClients(
      status: filter,
      q: q,
      page: page,
    );
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
