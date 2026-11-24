import 'package:dio/dio.dart';

import 'package:bnood/core/network/api/api_response_parser.dart';
import 'package:bnood/core/network/api/app_dio.dart';
import 'package:bnood/core/network/api/auth_api_exception.dart';
import 'package:bnood/core/network/api/auth_interceptor.dart';
import 'package:bnood/core/data/storage/session_store.dart';
import 'package:bnood/features/notifications/data/inbox_notification_record.dart';

class NotificationsApi {
  NotificationsApi({Dio? dio, SessionStore? sessionStore})
    : _dio = dio ?? createAppDio(sessionStore ?? SessionStore()),
      _ownsDio = dio == null;

  final Dio _dio;
  final bool _ownsDio;

  static const _prefix = '/v1/notifications';

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

  Future<InboxNotificationsPage> list({
    required int page,
    required int perPage,
  }) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        _prefix,
        queryParameters: {'page': page, 'per_page': perPage},
        options: Options(extra: _authenticatedExtra),
      );
      final json = ApiResponseParser.decodeJson(response);
      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300 || json['success'] != true) {
        throw ApiResponseParser.fromFailure(response, json);
      }
      final data = json['data'];
      if (data is! List) {
        throw AuthApiException(
          statusCode: statusCode,
          message: 'Unexpected response shape',
        );
      }
      final meta = json['meta'] as Map<String, dynamic>? ?? const {};
      final items = data
          .map(
            (e) => InboxNotificationRecord.fromJson(e as Map<String, dynamic>),
          )
          .toList();
      final currentPage =
          (meta['current_page'] as num?)?.toInt() ?? page;
      final resolvedPerPage = (meta['per_page'] as num?)?.toInt() ?? perPage;
      final total = (meta['total'] as num?)?.toInt() ?? items.length;
      return InboxNotificationsPage(
        items: items,
        page: currentPage,
        perPage: resolvedPerPage,
        total: total,
      );
    });
  }

  Future<int> unreadCount() {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_prefix/unread-count',
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(response, (json) {
        return (json?['unread_count'] as num?)?.toInt() ?? 0;
      });
    });
  }

  Future<InboxNotificationRecord> markRead(String id) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_prefix/$id/read',
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => InboxNotificationRecord.fromJson(json ?? const {}),
      );
    });
  }

  Future<int> markAllRead() {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_prefix/read-all',
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => (json?['updated'] as num?)?.toInt() ?? 0,
      );
    });
  }
}