import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/core/api/items_api.dart';
import 'package:bnood/core/items/item_api_record.dart';
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

    test('delete succeeds for soft delete even when item is in use', () async {
      final api = _itemsApi(
        (_) async => jsonResponse('{"success":true,"message":"ok"}'),
      );
      await api.deleteItem('01J');
      api.close();
    });
  });
}
