import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/providers/data/app_provider_record.dart';
import 'package:bnood/features/providers/data/providers_riverpod.dart';
import '../../../../core/shared/pagination/pagination.dart';

const providersListPageSize = 50;

enum ProvidersListTypeFilter { all, supplier, craftsman }

final providersListTypeFilterProvider = StateProvider<ProvidersListTypeFilter>(
  (ref) => ProvidersListTypeFilter.all,
);

final providersListSearchQueryProvider = StateProvider<String>((ref) => '');

AppProviderType? _apiTypeFor(ProvidersListTypeFilter filter) =>
    switch (filter) {
      ProvidersListTypeFilter.all => null,
      ProvidersListTypeFilter.supplier => AppProviderType.supplier,
      ProvidersListTypeFilter.craftsman => AppProviderType.craftsman,
    };

final providersListPagingProvider = Provider<PagedFetchCallback<AppProvider>>((
  ref,
) {
  return ({required int page, required int pageSize}) async {
    final repo = ref.read(appProvidersRepositoryProvider);
    final typeFilter = ref.read(providersListTypeFilterProvider);
    final q = ref.read(providersListSearchQueryProvider);
    final result = await repo.listProviders(
      q: q.trim().isEmpty ? null : q.trim(),
      type: _apiTypeFor(typeFilter),
      page: page,
      perPage: pageSize,
    );
    return PagedFetchPage(items: result.items, hasMore: result.hasMore);
  };
});
