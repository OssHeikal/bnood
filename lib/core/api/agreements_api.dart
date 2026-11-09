import 'package:dio/dio.dart';

import '../agreements/app_agreement_record.dart';
import 'api_response_parser.dart';
import 'app_dio.dart';
import 'auth_api_exception.dart';
import 'auth_interceptor.dart';
import '../storage/session_store.dart';

class AgreementsApi {
  AgreementsApi({
    Dio? dio,
    SessionStore? sessionStore,
  })  : _dio = dio ?? createAppDio(sessionStore ?? SessionStore()),
        _ownsDio = dio == null;

  final Dio _dio;
  final bool _ownsDio;

  static const _prefix = '/v1/agreements';

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

  Future<AgreementsListPage> listClientAgreements({
    required String clientId,
    int page = 1,
    int perPage = 50,
  }) {
    return _listNested('/v1/clients/$clientId/agreements', page: page, perPage: perPage);
  }

  Future<AgreementsListPage> listProviderAgreements({
    required String providerId,
    int page = 1,
    int perPage = 50,
  }) {
    return _listNested('/v1/providers/$providerId/agreements', page: page, perPage: perPage);
  }

  Future<AgreementsListPage> _listNested(
    String path, {
    required int page,
    required int perPage,
  }) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: {
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
          .map((e) => AppAgreement.fromDataJson(e as Map<String, dynamic>))
          .toList();
      return AgreementsListPage(
        items: items,
        page: (meta['page'] as num?)?.toInt() ?? page,
        perPage: (meta['per_page'] as num?)?.toInt() ?? perPage,
        total: (meta['total'] as num?)?.toInt() ?? items.length,
      );
    });
  }

  Future<AppAgreement> getAgreement(String id) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/$id',
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => AppAgreement.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<AppAgreement> createAgreement({
    required String clientId,
    required String providerId,
    int? amountPiastres,
    bool omitAmount = false,
  }) {
    return _guard(() async {
      final body = <String, dynamic>{
        'client_id': clientId,
        'provider_id': providerId,
      };
      if (!omitAmount) {
        body['amount'] = amountPiastres;
      }
      final response = await _dio.post<Map<String, dynamic>>(
        _prefix,
        data: body,
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => AppAgreement.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<AppAgreement> patchAgreement({
    required String id,
    required int? amountPiastres,
  }) {
    return _guard(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        '$_prefix/$id',
        data: {'amount': amountPiastres},
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => AppAgreement.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<void> deleteAgreement(String id) {
    return _guard(() async {
      final response = await _dio.delete<Map<String, dynamic>>(
        '$_prefix/$id',
        options: Options(extra: _authenticatedExtra),
      );
      ApiResponseParser.expectSuccess(response);
    });
  }
}
