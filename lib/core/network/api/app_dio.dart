import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_dio/sentry_dio.dart';

import '../../services/config/api_config.dart';
import '../../services/error_reporting/sentry_config.dart';
import '../../data/storage/session_store.dart';
import 'accept_language_interceptor.dart';
import 'api_log_interceptor.dart';
import 'auth_interceptor.dart';

/// Shared Dio instance for subscriber auth API calls.
Dio createAppDio(SessionStore store) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {Headers.acceptHeader: 'application/json'},
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );
  // Auth before log on requests (final headers). Log must stay last so its
  // onError runs after auth maps failures (auth reject uses callFollowing).
  dio.interceptors.add(AcceptLanguageInterceptor());
  dio.interceptors.add(AuthInterceptor(store));
  if (kDebugMode) {
    dio.interceptors.add(ApiLogInterceptor());
  }
  if (SentryConfig.isEnabled) {
    dio.addSentry(captureFailedRequests: false);
  }
  return dio;
}
