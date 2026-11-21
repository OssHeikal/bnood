import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/features/items/data/items_api.dart';
import 'package:bnood/features/items/data/item_api_record.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

ItemsApi _itemsApi(Future<ResponseBody> Function(RequestOptions options) handler) {
  final dio = createAppDio(FakeSessionStore(token: 'tok'));
  dio.httpClientAdapter = ScriptedDioAdapter(handler);
  return ItemsApi(dio: dio);
}

void main() {
  group('CatalogItem', () {
    test('fromDataJson maps icon and color keys', () {
      final item = CatalogItem.fromDataJson({
        'id': '01JITEM',
        'name': 'Insulation',
        'icon_key': 'layers',
        'color_key': 'teal',
        'is_default': true,
        'sort_order': 1,
        'created_at': '2026-11-09T10:00:00Z',
        'updated_at': '2026-11-09T10:00:00Z',
      });
      expect(item.iconKey, 'layers');
      expect(item.colorKey, 'teal');
      expect(item.isDefault, isTrue);
      expect(item.isCustomized, isFalse);
    });

    test('fromDataJson maps is_customized', () {
      final item = CatalogItem.fromDataJson({
        'id': '01JITEM',
        'name': 'Insulation',
        'icon_key': 'layers',
        'color_key': 'teal',
        'is_default': true,
        'is_customized': true,
        'sort_order': 1,
        'created_at': '2026-11-09T10:00:00Z',
        'updated_at': '2026-11-09T10:00:00Z',
      });
      expect(item.isCustomized, isTrue);
    });
  });

  group('ItemsApi', () {
    test('list sends bearer and pagination', () async {
      late RequestOptions captured;
      final api = _itemsApi((options) async {
        captured = options;
        return jsonResponse(
          '{"success":true,"data":[],"meta":{"page":1,"per_page":50,"total":0}}',
        );
      });
      await api.listItems(q: 'عزل', page: 2);
      expect(captured.headers['Authorization'], 'Bearer tok');
      expect(captured.queryParameters['q'], 'عزل');
      expect(captured.queryParameters['page'], 2);
      api.close();
    });

    test('icons parses envelope and bare payload', () async {
      final enveloped = _itemsApi(
        (_) async => jsonResponse(
          '{"success":true,"data":{"colors":[{"key":"teal","hex":"#0D9B8A"}],"icons":["layers"]}}',
        ),
      );
      final catalog = await enveloped.fetchIconsCatalog();
      expect(catalog.iconKeys, ['layers']);
      expect(catalog.colors.single.key, 'teal');
      enveloped.close();

      final bare = _itemsApi(
        (_) async => jsonResponse('{"colors":[],"icons":["category"]}'),
      );
      expect((await bare.fetchIconsCatalog()).iconKeys, ['category']);
      bare.close();
    });

    test('create duplicate_name on 422', () async {
      final api = _itemsApi(
        (_) async => jsonResponse(
          '{"success":false,"message":"dup","code":"duplicate_name"}',
          statusCode: 422,
        ),
      );
      expect(
        () => api.createItem(name: 'X', iconKey: 'category', colorKey: 'teal'),
        throwsA(isA<AuthApiException>().having((e) => e.isDuplicateName, 'dup', isTrue)),
      );
      api.close();
    });

    test('reorder sends ordered id list', () async {
      late RequestOptions captured;
      final api = _itemsApi((options) async {
        captured = options;
        return jsonResponse('{"success":true,"message":"ok","data":null}');
      });
      await api.reorderItems(['01A', '01B']);
      expect(captured.method, 'PUT');
      expect(captured.path, endsWith('/v1/items/reorder'));
      expect(captured.data, {'ids': ['01A', '01B']});
      api.close();
    });

    test('delete parses deleted result for unused item', () async {
      late RequestOptions captured;
      final api = _itemsApi((options) async {
        captured = options;
        return jsonResponse('{"success":true,"message":"ok","data":{"id":"01J","result":"deleted"}}');
      });
      final result = await api.deleteItem('01J');
      expect(captured.method, 'DELETE');
      expect(captured.path, endsWith('/v1/items/01J'));
      expect(result, ItemDeleteResult.deleted);
      api.close();
    });

    test('delete parses archived result for linked or default item', () async {
      final api = _itemsApi(
        (_) async => jsonResponse('{"success":true,"message":"ok","data":{"id":"01J","result":"archived"}}'),
      );
      expect(await api.deleteItem('01J'), ItemDeleteResult.archived);
      api.close();
    });

    test('delete without result payload is treated as deleted', () async {
      final api = _itemsApi(
        (_) async => jsonResponse('{"success":true,"message":"ok"}'),
      );
      expect(await api.deleteItem('01J'), ItemDeleteResult.deleted);
      api.close();
    });
  });
}
