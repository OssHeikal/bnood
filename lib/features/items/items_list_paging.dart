import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/items/item_api_record.dart';
import '../../core/items/items_providers.dart';
import '../../core/shared/pagination/pagination.dart';

const itemsListPageSize = 50;

final itemsListPageFetcherProvider = Provider<PagedFetchCallback<CatalogItem>>((ref) {
  return ({required int page, required int pageSize}) async {
    if (!ref.read(remoteItemsEnabledProvider)) {
      if (page > 1) {
        return const PagedFetchPage(items: [], hasMore: false);
      }
      return const PagedFetchPage(items: [], hasMore: false);
    }
    final repo = ref.read(itemsRepositoryProvider);
    final result = await repo.listItems(page: page, perPage: pageSize);
    return PagedFetchPage(
      items: result.items,
      hasMore: result.hasMore,
    );
  };
});
