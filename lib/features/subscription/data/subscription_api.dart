import 'package:dio/dio.dart';

import 'app_subscription.dart';
import 'package:bnood/core/api/api_response_parser.dart';
import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/core/api/auth_interceptor.dart';
import 'package:bnood/core/storage/session_store.dart';

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

  Future<AppSubscriptionSnapshot> getSubscription({
    required String languageCode,
    PaywallFetchTrigger? paywallTrigger,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/subscription',
        queryParameters: paywallTrigger != null ? {'paywall_trigger': paywallTrigger.queryParameter} : null,
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (data) => AppSubscriptionSnapshot.fromDataJson(data ?? const {}, localeCode: languageCode),
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
