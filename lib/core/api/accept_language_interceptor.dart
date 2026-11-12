import 'package:dio/dio.dart';

import 'api_accept_language.dart';

/// Sends current app locale on every API request.
class AcceptLanguageInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = ApiAcceptLanguage.headerValue();
    handler.next(options);
  }
}
