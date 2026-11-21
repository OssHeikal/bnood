import 'package:dio/dio.dart';

import 'api_response_parser.dart';
import 'app_dio.dart';
import 'auth_api_exception.dart';
import 'auth_interceptor.dart';
import '../storage/session_store.dart';

class DeviceTokensApi {
  DeviceTokensApi({Dio? dio, SessionStore? sessionStore})
    : _dio = dio ?? createAppDio(sessionStore ?? SessionStore()),
      _ownsDio = dio == null;

  final Dio _dio;
  final bool _ownsDio;

  static const _prefix = '/v1/device-tokens';

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
    } catch (e) {
      throw ApiResponseParser.transport(e);
    }
  }

  Future<void> registerToken({
    required String token,
    required String platform,
    required String locale,
  }) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        _prefix,
        data: {'token': token, 'platform': platform, 'locale': locale},
        options: Options(extra: _authenticatedExtra),
      );
      ApiResponseParser.expectSuccess(response);
    });
  }

  Future<void> deleteToken({required String token}) {
    return _guard(() async {
      final response = await _dio.delete<Map<String, dynamic>>(
        _prefix,
        data: {'token': token},
        options: Options(extra: _authenticatedExtra),
      );
      ApiResponseParser.expectSuccess(response);
    });
  }
}
