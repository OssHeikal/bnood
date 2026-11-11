import 'package:dio/dio.dart';

import '../items/item_api_record.dart';
import 'api_response_parser.dart';
import 'app_dio.dart';
import 'auth_api_exception.dart';
import 'auth_interceptor.dart';
import '../storage/session_store.dart';

class ItemsApi {
  ItemsApi({
    Dio? dio,
    SessionStore? sessionStore,
  })  : _dio = dio ?? createAppDio(sessionStore ?? SessionStore()),
        _ownsDio = dio == null;

  final Dio _dio;
  final bool _ownsDio;

  static const _prefix = '/v1/items';

  Map<String, dynamic> get _authenticatedExtra => {
        AuthInterceptor.authenticatedExtraKey: true,
      };

  void close({bool force = false}) {
    if (_ownsDio) {
      _dio.close(force: force);
    }
  }

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on AuthApiException {
      rethrow;
    } on DioException catch (e) {
      if (e.error is AuthApiException) {
        throw e.error as AuthApiException;
      }
      throw ApiResponseParser.transport(e);
    } catch (e) {
      throw ApiResponseParser.transport(e);
    }
  }

  static Map<String, dynamic> _unwrapPayload(Map<String, dynamic> json) {
    if (json['success'] == true) {
      final data = json['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is List) return {'items': data};
    }
    if (json.containsKey('colors') || json.containsKey('icons')) return json;
    if (json.containsKey('id') && json.containsKey('name')) return json;
    return json;
  }

  Future<ItemIconsCatalog> fetchIconsCatalog() {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/icons',
        options: Options(extra: _authenticatedExtra),
      );
      final json = ApiResponseParser.decodeJson(response);
      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) {
        if (json['success'] == false) {
          throw ApiResponseParser.fromFailure(response, json);
        }
        final payload = _unwrapPayload(json);
        return ItemIconsCatalog.fromJson(payload);
      }
      throw ApiResponseParser.fromFailure(response, json);
    });
  }

  Future<ItemsListPage> listItems({
    String? q,
    int page = 1,
    int perPage = 50,
  }) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        _prefix,
        queryParameters: {
          if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
          'page': page,
          'per_page': perPage,
        },
        options: Options(extra: _authenticatedExtra),
      );
      final json = ApiResponseParser.decodeJson(response);
      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300 || json['success'] != true) {
        throw ApiResponseParser.fromFailure(response, json);
      }
      final data = json['data'];
      if (data is! List) {
        throw AuthApiException(statusCode: statusCode, message: 'Unexpected response shape');
      }
      final meta = json['meta'] as Map<String, dynamic>? ?? const {};
      final items = data
          .map((e) => CatalogItem.fromDataJson(e as Map<String, dynamic>))
          .toList();
      return ItemsListPage(
        items: items,
        page: (meta['page'] as num?)?.toInt() ?? page,
        perPage: (meta['per_page'] as num?)?.toInt() ?? perPage,
        total: (meta['total'] as num?)?.toInt() ?? items.length,
      );
    });
  }

  Future<CatalogItem> getItem(String id) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/$id',
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => CatalogItem.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<CatalogItem> createItem({
    required String name,
    required String iconKey,
    required String colorKey,
  }) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        _prefix,
        data: {
          'name': name,
          'icon_key': iconKey,
          'color_key': colorKey,
        },
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => CatalogItem.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<CatalogItem> updateItem({
    required String id,
    String? name,
    String? iconKey,
    String? colorKey,
  }) {
    return _guard(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        '$_prefix/$id',
        data: {
          if (name != null) 'name': name,
          if (iconKey != null) 'icon_key': iconKey,
          if (colorKey != null) 'color_key': colorKey,
        },
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => CatalogItem.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<void> deleteItem(String id) {
    return _guard(() async {
      final response = await _dio.delete<Map<String, dynamic>>(
        '$_prefix/$id',
        options: Options(extra: _authenticatedExtra),
      );
      ApiResponseParser.expectSuccess(response);
    });
  }

  Future<void> reorderItems(List<String> ids) {
    return _guard(() async {
      final response = await _dio.put<Map<String, dynamic>>(
        '$_prefix/reorder',
        data: {'ids': ids},
        options: Options(extra: _authenticatedExtra),
      );
      ApiResponseParser.expectSuccess(response);
    });
  }
}
