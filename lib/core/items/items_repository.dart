import '../api/items_api.dart';
import 'item_api_record.dart';

class ItemsRepository {
  ItemsRepository(this._api);

  final ItemsApi _api;

  Future<ItemIconsCatalog> fetchIconsCatalog() => _api.fetchIconsCatalog();

  Future<ItemsListPage> listItems({
    String? q,
    int page = 1,
    int perPage = 50,
  }) =>
      _api.listItems(q: q, page: page, perPage: perPage);

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
}

Future<List<CatalogItem>> fetchAllCatalogItems(
  ItemsRepository repository, {
  String? q,
  int perPage = 50,
}) async {
  final all = <CatalogItem>[];
  var page = 1;
  while (true) {
    final result = await repository.listItems(q: q, page: page, perPage: perPage);
    all.addAll(result.items);
    if (!result.hasMore) break;
    page++;
  }
  return all;
}
