import 'package:dio/dio.dart';

import 'api_accept_language.dart';
import '../subscription/app_subscription.dart';
import 'api_response_parser.dart';
import 'app_dio.dart';
import 'auth_api_exception.dart';
import 'auth_interceptor.dart';
import '../storage/session_store.dart';

class SubscriptionApi {
  SubscriptionApi({
    Dio? dio,
    SessionStore? sessionStore,
  })  : _dio = dio ?? createAppDio(sessionStore ?? SessionStore()),
        _ownsDio = dio == null;

  final Dio _dio;
  final bool _ownsDio;

  Map<String, dynamic> get _authenticatedExtra => {
        AuthInterceptor.authenticatedExtraKey: true,
      };

  void close({bool force = false}) {
    if (_ownsDio) {
      _dio.close(force: force);
    }
  }

  Future<AppSubscriptionSnapshot> getSubscription({required String languageCode}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/subscription',
        options: Options(
          extra: _authenticatedExtra,
          headers: {
            'Accept-Language': acceptLanguageHeaderForLocale(languageCode),
          },
        ),
      );
      return ApiResponseParser.expectData(
        response,
        (data) => AppSubscriptionSnapshot.fromDataJson(data ?? const {}),
      );
    } on AuthApiException {
      rethrow;
    } on DioException catch (e) {
      if (e.error is AuthApiException) {
        throw e.error as AuthApiException;
      }
      throw ApiResponseParser.fromDio(e);
    }
  }
}
