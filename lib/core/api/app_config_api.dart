import 'package:dio/dio.dart';

import 'api_response_parser.dart';
import 'app_dio.dart';
import 'auth_api_exception.dart';
import '../app_gate/app_config_record.dart';
import '../storage/session_store.dart';

class AppConfigApi {
  AppConfigApi({
    Dio? dio,
    SessionStore? sessionStore,
  })  : _dio = dio ?? createAppDio(sessionStore ?? SessionStore()),
        _ownsDio = dio == null;

  final Dio _dio;
  final bool _ownsDio;

  static const _prefix = '/v1/app/config';

  void close({bool force = false}) {
    if (_ownsDio) {
      _dio.close(force: force);
    }
  }

  Future<AppConfigData> fetchConfig({
    required String platform,
    required String version,
    required String locale,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _prefix,
        queryParameters: {
          'platform': platform,
          'version': version,
          'locale': locale,
        },
      );
      return ApiResponseParser.expectData(response, AppConfigData.fromDataJson);
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
}
