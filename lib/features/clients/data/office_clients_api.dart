import 'package:dio/dio.dart';

import 'package:bnood/core/data/storage/session_store.dart';
import 'package:bnood/core/network/api/api_response_parser.dart';
import 'package:bnood/core/network/api/app_dio.dart';
import 'package:bnood/core/network/api/auth_api_exception.dart';
import 'package:bnood/core/network/api/auth_interceptor.dart';

import 'office_client_detail_record.dart';

class OfficeClientsApi {
  OfficeClientsApi({Dio? dio, SessionStore? sessionStore})
    : _dio = dio ?? createAppDio(sessionStore ?? SessionStore()),
      _ownsDio = dio == null;

  final Dio _dio;
  final bool _ownsDio;

  static const _prefix = '/v1/office/clients';

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
      throw ApiResponseParser.fromDio(e);
    } catch (e, stackTrace) {
      throw ApiResponseParser.fromUnexpected(e, stackTrace);
    }
  }

  Future<OfficeClientDetailRecord> getClient(String clientId) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/$clientId',
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => OfficeClientDetailRecord.fromJson(json ?? const {}),
      );
    });
  }
}