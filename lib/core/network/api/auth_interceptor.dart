import 'package:dio/dio.dart';

import '../../account/api_office_header.dart';
import '../../data/storage/session_store.dart';
import 'api_response_parser.dart';
import 'auth_api_exception.dart';

/// Attaches bearer token for authenticated calls and maps [DioException] to [AuthApiException].
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._store);

  final SessionStore _store;

  static const authenticatedExtraKey = 'authenticated';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[authenticatedExtraKey] == true) {
      final token = await _store.readToken();
      if (token == null || token.isEmpty) {
        return handler.reject(
          DioException(
            requestOptions: options,
            error: AuthApiException(
              statusCode: 401,
              message: 'No session',
              code: 'unauthorized',
            ),
          ),
          true,
        );
      }
      options.headers['Authorization'] = 'Bearer $token';
      final officeId = ApiOfficeHeader.headerValue();
      if (officeId != null) {
        options.headers[ApiOfficeHeader.headerName] = officeId;
      } else {
        options.headers.remove(ApiOfficeHeader.headerName);
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is AuthApiException) {
      handler.reject(err, true);
      return;
    }
    final mapped = ApiResponseParser.fromDio(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: mapped,
        message: err.message,
      ),
      true,
    );
  }
}
