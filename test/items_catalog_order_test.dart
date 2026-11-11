import 'package:bnood/core/items/item_api_record.dart';
import 'package:bnood/features/items/items_catalog_order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 11, 11);

  CatalogItem item(String id, {bool isDefault = false}) => CatalogItem(
        id: id,
        name: id,
        iconKey: 'layers',
        colorKey: 'teal',
        isDefault: isDefault,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      );

  test('reorderCatalogItems permutes full list including defaults', () {
    final all = [item('a'), item('b'), item('d', isDefault: true), item('c')];
    final next = reorderCatalogItems(all, oldIndex: 0, newIndex: 3);
    expect(next.map((e) => e.id), ['b', 'd', 'c', 'a']);
  });

  test('reorderCatalogItems can move default among user items', () {
    final all = [item('a'), item('d', isDefault: true), item('b')];
    final next = reorderCatalogItems(all, oldIndex: 1, newIndex: 0);
    expect(next.map((e) => e.id), ['d', 'a', 'b']);
  });

  test('reorder rejects out-of-range indices', () {
    final all = [item('a'), item('d', isDefault: true)];
    expect(reorderCatalogItems(all, oldIndex: 2, newIndex: 0), all);
    expect(reorderCatalogItems(all, oldIndex: 0, newIndex: 5), all);
  });

  test('catalogItemIdsInOrder includes defaults', () {
    final ids = catalogItemIdsInOrder([item('x'), item('z', isDefault: true), item('y')]);
    expect(ids, ['x', 'z', 'y']);
  });
}
