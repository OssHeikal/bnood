import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clients/clients_providers.dart';
import '../../core/clients/clients_repository.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/dashboard_providers.dart';
import '../../core/repositories/bnood_repository.dart';
import '../../core/shared/pagination/pagination.dart';
import '../../core/clients/client_list_local_search.dart';

const clientsListPageSize = 50;

final clientsListPageFetcherProvider = Provider<PagedFetchCallback<HomeClientBalanceRow>>((ref) {
  return ({required int page, required int pageSize}) async {
    if (ref.read(remoteClientsEnabledProvider)) {
      final clientsRepo = ref.read(clientsRepositoryProvider);
      final filter = ref.read(clientsListFilterProvider);
      final q = ref.read(clientsListSearchQueryProvider);
      final result = await clientsRepo.listClients(
        status: filter,
        q: q,
        page: page,
        perPage: pageSize,
      );
      return PagedFetchPage(
        items: result.items.map(balanceRowFromRecord).toList(),
        hasMore: result.hasMore,
      );
    }
    if (page > 1) {
      return const PagedFetchPage(items: [], hasMore: false);
    }
    final repo = ref.read(repositoryProvider);
    final filter = ref.read(clientsListFilterProvider);
    final q = ref.read(clientsListSearchQueryProvider);
    final clients = await repo.listClients(filter);
    final rows = filterHomeClientRowsBySearch(
      await homeClientBalanceRows(repo, clients, activeProjectsOnly: false),
      q,
    );
    return PagedFetchPage(items: rows, hasMore: false);
  };
});
