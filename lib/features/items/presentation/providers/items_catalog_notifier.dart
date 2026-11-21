import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/items/data/item_api_record.dart';
import 'package:bnood/features/items/data/items_providers.dart';
import '../../data/items_repository.dart' show fetchAllCatalogItems;
import '../../../../core/shared/pagination/paging_refresh.dart';
import 'package:bnood/features/items/presentation/models/items_catalog_order.dart';

class ItemsCatalogNotifier extends Notifier<AsyncValue<List<CatalogItem>>> {
  @override
  AsyncValue<List<CatalogItem>> build() {
    ref.listen(pagingListRefreshEpochProvider(PagingListIds.items), (
      previous,
      next,
    ) {
      if (previous != next) {
        Future.microtask(reload);
      }
    });
    Future.microtask(reload);
    return const AsyncValue.loading();
  }

  Future<void> reload() async {
    final previous = state.valueOrNull;
    if (previous == null) {
      state = const AsyncValue.loading();
    }
    state = await AsyncValue.guard(() async {
      return fetchAllCatalogItems(ref.read(itemsRepositoryProvider));
    });
  }

  Future<void> reorderCatalogItem({
    required int oldIndex,
    required int newIndex,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (oldIndex < 0 ||
        oldIndex >= current.length ||
        newIndex < 0 ||
        newIndex >= current.length) {
      return;
    }
    if (oldIndex == newIndex) return;

    final snapshot = current;
    final optimistic = reorderCatalogItems(
      current,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
    state = AsyncValue.data(optimistic);

    try {
      await ref
          .read(itemsRepositoryProvider)
          .reorderItems(catalogItemIdsInOrder(optimistic));
    } catch (e) {
      state = AsyncValue.data(snapshot);
      Error.throwWithStackTrace(e, StackTrace.current);
    }
  }
}

final itemsCatalogProvider =
    NotifierProvider<ItemsCatalogNotifier, AsyncValue<List<CatalogItem>>>(
      ItemsCatalogNotifier.new,
    );
