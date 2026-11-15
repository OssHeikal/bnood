import '../api/items_api.dart';
import 'item_api_record.dart';
import 'item_icon_catalog.dart';

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
  }) =>
      _api.listItems(q: q, page: page, perPage: perPage, status: status.queryValue);

  Future<CatalogItem> getItem(String id) => _api.getItem(id);

  Future<CatalogItem> createItem({
    required String name,
    required String iconKey,
    required String colorKey,
  }) =>
      _api.createItem(name: name, iconKey: iconKey, colorKey: colorKey);

  Future<CatalogItem> updateItem({
    required String id,
    String? name,
    String? iconKey,
    String? colorKey,
  }) =>
      _api.updateItem(id: id, name: name, iconKey: iconKey, colorKey: colorKey);

  Future<void> deleteItem(String id) => _api.deleteItem(id);

  Future<CatalogItem> archiveItem(String id) => _api.archiveItem(id);

  Future<CatalogItem> unarchiveItem(String id) => _api.unarchiveItem(id);

  Future<void> reorderItems(List<String> ids) => _api.reorderItems(ids);
}

enum ItemCatalogListStatus { active, archived, all }

extension ItemCatalogListStatusQuery on ItemCatalogListStatus {
  String? get queryValue => switch (this) {
        ItemCatalogListStatus.active => 'active',
        ItemCatalogListStatus.archived => 'archived',
        ItemCatalogListStatus.all => 'all',
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
    final result = await repository.listItems(q: q, page: page, perPage: perPage, status: status);
    all.addAll(result.items);
    if (!result.hasMore) break;
    page++;
  }
  if (status == ItemCatalogListStatus.all) return all;
  return all.where((item) {
    final archived = item.isArchived;
    return status == ItemCatalogListStatus.archived ? archived : !archived;
  }).toList();
}
