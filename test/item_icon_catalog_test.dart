import 'package:bnood/core/items/item_api_record.dart';
import 'package:bnood/core/items/item_icon_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('itemIconCatalogKeys is 27 unique keys including layers', () {
    expect(itemIconCatalogKeys.length, 27);
    expect(itemIconCatalogKeys.toSet().length, 27);
    expect(itemIconCatalogKeys, contains('layers'));
    expect(itemIconCatalogKeys, contains('sofa'));
    expect(itemIconCatalogKeys, contains('sofa_single'));
    expect(itemIconCatalogKeys, contains('grid_table'));
    expect(itemIconCatalogKeys, contains('dashboard_square'));
    expect(itemIconCatalogKeys, contains('windows'));
    expect(itemIconCatalogKeys.last, 'layers');
  });

  test('withFullItemIconCatalog returns exactly 27 keys when API sends subset', () {
    const partial = ItemIconsCatalog(
      colors: [],
      iconKeys: ['layers', 'bathtub', 'sink'],
    );
    final full = withFullItemIconCatalog(partial);
    expect(full.iconKeys.length, 27);
    expect(full.iconKeys.toSet().length, 27);
    expect(full.iconKeys, itemIconCatalogKeys);
    expect(full.iconKeys, contains('layers'));
  });

  test('withFullItemIconCatalog does not duplicate when API sends full or mixed lists', () {
    const fromApi = ItemIconsCatalog(
      colors: [ItemColorOption(key: 'teal', hex: '#0D9B8A')],
      iconKeys: [
        ...itemIconCatalogKeys,
        'plumbing',
        'category',
        'brick_wall',
        'paint_roller',
      ],
    );
    final full = withFullItemIconCatalog(fromApi);
    expect(full.iconKeys.length, 27);
    expect(full.iconKeys.toSet().length, 27);
    expect(full.iconKeys, itemIconCatalogKeys);
    expect(full.colors.length, 1);
  });
}
