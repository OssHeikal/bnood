import 'package:dio/dio.dart';

import '../content/content_page_record.dart';
import 'api_response_parser.dart';
import 'app_dio.dart';
import 'auth_api_exception.dart';
import '../storage/session_store.dart';

class PagesApi {
  PagesApi({
    Dio? dio,
    SessionStore? sessionStore,
  })  : _dio = dio ?? createAppDio(sessionStore ?? SessionStore()),
        _ownsDio = dio == null;

  final Dio _dio;
  final bool _ownsDio;

  void close({bool force = false}) {
    if (_ownsDio) {
      _dio.close(force: force);
    }
  }

  Future<ContentPage> getPage({required String slug, required String locale}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/pages/$slug',
        queryParameters: {'locale': locale},
      );
      return ApiResponseParser.expectData(response, ContentPage.fromDataJson);
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
