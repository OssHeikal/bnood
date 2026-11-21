import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/clients/data/clients_providers.dart';
import 'package:bnood/features/clients/data/clients_repository.dart';
import 'package:bnood/features/home/data/home_row_models.dart';
import '../../../../core/shared/pagination/pagination.dart';
import 'package:bnood/features/clients/presentation/providers/clients_list_providers.dart';

const clientsListPageSize = 50;

final clientsListPageFetcherProvider =
    Provider<PagedFetchCallback<HomeClientBalanceRow>>((ref) {
      return ({required int page, required int pageSize}) async {
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
      };
    });
