import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/items/data/items_api.dart';
import 'package:bnood/core/data/storage/session_store.dart';
import 'package:bnood/features/items/data/item_api_record.dart';
import 'package:bnood/features/items/data/items_repository.dart';

final itemsApiProvider = Provider<ItemsApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = ItemsApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});

final itemsRepositoryProvider = Provider<ItemsRepository>((ref) {
  return ItemsRepository(ref.watch(itemsApiProvider));
});

final itemIconsCatalogProvider = FutureProvider.autoDispose<ItemIconsCatalog>((
  ref,
) {
  return ref.watch(itemsRepositoryProvider).fetchIconsCatalog();
});

/// Full items catalog keyed by id (for statement row icon resolution and pickers).
final itemsCatalogByIdProvider = FutureProvider<Map<String, CatalogItem>>((
  ref,
) async {
  try {
    final repo = ref.read(itemsRepositoryProvider);
    final active = await fetchAllCatalogItems(repo);
    final archived = await fetchAllCatalogItems(
      repo,
      status: ItemCatalogListStatus.archived,
    );
    return {
      for (final item in [...archived, ...active]) item.id: item,
    };
  } catch (_) {
    return const {};
  }
});
