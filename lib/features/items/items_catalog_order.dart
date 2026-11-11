import '../../core/items/item_api_record.dart';

/// Reorder any visible catalog index (user + default items).
List<CatalogItem> reorderCatalogItems(
  List<CatalogItem> items, {
  required int oldIndex,
  required int newIndex,
}) {
  if (oldIndex < 0 || oldIndex >= items.length) return items;
  if (newIndex < 0 || newIndex >= items.length) return items;
  if (oldIndex == newIndex) return items;
  final next = List<CatalogItem>.from(items);
  final moved = next.removeAt(oldIndex);
  next.insert(newIndex, moved);
  return next;
}

List<String> catalogItemIdsInOrder(List<CatalogItem> items) => items.map((e) => e.id).toList();
