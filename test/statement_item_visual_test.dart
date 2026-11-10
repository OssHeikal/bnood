import 'package:bnood/core/clients/client_statement_record.dart';
import 'package:bnood/core/clients/statement_item_visual.dart';
import 'package:bnood/core/items/item_api_record.dart';
import 'package:flutter_test/flutter_test.dart';

CatalogItem _catalogItem({required String id, String iconKey = 'bathtub', String colorKey = 'blue'}) {
  return CatalogItem(
    id: id,
    name: 'Item $id',
    iconKey: iconKey,
    colorKey: colorKey,
    isDefault: false,
    sortOrder: 0,
    createdAt: DateTime.utc(2020),
    updatedAt: DateTime.utc(2020),
  );
}

void main() {
  group('AppClientStatementItemSpend.fromDataJson', () {
    test('leaves icon and color null when omitted', () {
      final item = AppClientStatementItemSpend.fromDataJson({
        'id': 'i1',
        'name': 'Tiles',
        'spent': 500_000,
      });
      expect(item.iconKey, isNull);
      expect(item.colorKey, isNull);
    });

    test('reads icon_key and color_key when present', () {
      final item = AppClientStatementItemSpend.fromDataJson({
        'id': 'i1',
        'name': 'Plumbing',
        'spent': 100,
        'icon_key': 'sink',
        'color_key': 'turquoise',
      });
      expect(item.iconKey, 'sink');
      expect(item.colorKey, 'turquoise');
    });
  });

  group('resolveStatementItemVisual', () {
    test('uses response keys when present', () {
      final item = AppClientStatementItemSpend.fromDataJson({
        'id': 'i1',
        'name': 'X',
        'spent': 1,
        'icon_key': 'bathtub',
        'color_key': 'blue',
      });
      final visual = resolveStatementItemVisual(
        item,
        catalogById: {'i1': _catalogItem(id: 'i1', iconKey: 'sink', colorKey: 'orange')},
      );
      expect(visual.iconKey, 'bathtub');
      expect(visual.colorKey, 'blue');
    });

    test('looks up catalog by item id when response omits icon', () {
      final item = AppClientStatementItemSpend.fromDataJson({
        'id': 'catalog-id',
        'name': 'سيراميك',
        'spent': 62_000,
      });
      final visual = resolveStatementItemVisual(
        item,
        catalogById: {'catalog-id': _catalogItem(id: 'catalog-id', iconKey: 'bathtub', colorKey: 'blue')},
      );
      expect(visual.iconKey, 'bathtub');
      expect(visual.colorKey, 'blue');
    });

    test('falls back to catalog defaults when API and catalog miss', () {
      final item = AppClientStatementItemSpend.fromDataJson({
        'id': 'missing',
        'name': 'Unknown',
        'spent': 1,
      });
      final visual = resolveStatementItemVisual(item, catalogById: const {});
      expect(visual.iconKey, statementItemDefaultIconKey);
      expect(visual.colorKey, statementItemDefaultColorKey);
    });
  });
}
