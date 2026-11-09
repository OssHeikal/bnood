import 'package:dio/dio.dart';

import '../providers_api/app_provider_record.dart';
import 'api_response_parser.dart';
import 'app_dio.dart';
import 'auth_api_exception.dart';
import 'auth_interceptor.dart';
import '../storage/session_store.dart';

class ProvidersApi {
  ProvidersApi({
    Dio? dio,
    SessionStore? sessionStore,
  })  : _dio = dio ?? createAppDio(sessionStore ?? SessionStore()),
        _ownsDio = dio == null;

  final Dio _dio;
  final bool _ownsDio;

  static const _prefix = '/v1/providers';

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

  Future<ProvidersListPage> listProviders({
    String? q,
    AppProviderType? type,
    int page = 1,
    int perPage = 50,
  }) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        _prefix,
        queryParameters: {
          if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
          if (type != null) 'type': type.apiValue,
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
          .map((e) => AppProvider.fromDataJson(e as Map<String, dynamic>))
          .toList();
      return ProvidersListPage(
        items: items,
        page: (meta['page'] as num?)?.toInt() ?? page,
        perPage: (meta['per_page'] as num?)?.toInt() ?? perPage,
        total: (meta['total'] as num?)?.toInt() ?? items.length,
      );
    });
  }

  Future<AppProvider> getProvider(String id) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/$id',
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => AppProvider.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<AppProvider> createProvider({
    required String name,
    required AppProviderType type,
    String? phone,
  }) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        _prefix,
        data: {
          'name': name,
          'type': type.apiValue,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => AppProvider.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<AppProvider> updateProvider({
    required String id,
    String? name,
    String? phone,
    bool clearPhone = false,
  }) {
    return _guard(() async {
      final body = <String, dynamic>{
        if (name != null) 'name': name,
      };
      if (clearPhone) {
        body['phone'] = '';
      } else if (phone != null) {
        body['phone'] = phone;
      }
      final response = await _dio.patch<Map<String, dynamic>>(
        '$_prefix/$id',
        data: body,
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => AppProvider.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<void> deleteProvider(String id) {
    return _guard(() async {
      final response = await _dio.delete<Map<String, dynamic>>(
        '$_prefix/$id',
        options: Options(extra: _authenticatedExtra),
      );
      ApiResponseParser.expectSuccess(response);
    });
  }
}
