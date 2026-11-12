import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../storage/session_store.dart';
import 'accept_language_interceptor.dart';
import 'api_log_interceptor.dart';
import 'auth_interceptor.dart';

/// Shared Dio instance for subscriber auth API calls.
Dio createAppDio(SessionStore store) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {
        Headers.acceptHeader: 'application/json',
      },
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
  return dio;
}
