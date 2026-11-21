import 'package:bnood/features/items/data/items_api.dart';
import 'package:bnood/features/items/data/item_api_record.dart';
import 'package:bnood/features/items/data/item_icon_catalog.dart';

class ItemsRepository {
  ItemsRepository(this._api);

  final ItemsApi _api;

  Future<ItemIconsCatalog> fetchIconsCatalog() async {
    final catalog = await _api.fetchIconsCatalog();
    return withFullItemIconCatalog(catalog);
  }

  Future<ItemsListPage> listItems({
    String? q,
    int page = 1,
    int perPage = 50,
    ItemCatalogListStatus status = ItemCatalogListStatus.active,
  }) => _api.listItems(
    q: q,
    page: page,
    perPage: perPage,
    status: status.queryValue,
  );

  Future<CatalogItem> getItem(String id) => _api.getItem(id);

  Future<CatalogItem> createItem({
    required String name,
    required String iconKey,
    required String colorKey,
  }) => _api.createItem(name: name, iconKey: iconKey, colorKey: colorKey);

  Future<CatalogItem> updateItem({
    required String id,
    String? name,
    String? iconKey,
    String? colorKey,
  }) =>
      _api.updateItem(id: id, name: name, iconKey: iconKey, colorKey: colorKey);

  /// Unified delete: the server hard-deletes unused own items and hides the rest.
  Future<ItemDeleteResult> deleteItem(String id) => _api.deleteItem(id);

  Future<void> reorderItems(List<String> ids) => _api.reorderItems(ids);
}

/// List filter sent to the API. The Items screen only shows [active]; [archived]
/// resolves names/icons of deleted items that still appear on past vouchers.
enum ItemCatalogListStatus { active, archived }

extension ItemCatalogListStatusQuery on ItemCatalogListStatus {
  String get queryValue => switch (this) {
    ItemCatalogListStatus.active => 'active',
    ItemCatalogListStatus.archived => 'archived',
  };
}

Future<List<CatalogItem>> fetchAllCatalogItems(
  ItemsRepository repository, {
  String? q,
  int perPage = 50,
  ItemCatalogListStatus status = ItemCatalogListStatus.active,
}) async {
  final all = <CatalogItem>[];
  var page = 1;
  while (true) {
    final result = await repository.listItems(
      q: q,
      page: page,
      perPage: perPage,
      status: status,
    );
    all.addAll(result.items);
    if (!result.hasMore) break;
    page++;
  }
  return all.where((item) {
    final archived = item.isArchived;
    return status == ItemCatalogListStatus.archived ? archived : !archived;
  }).toList();
}
