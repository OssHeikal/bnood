import 'package:dio/dio.dart';

import 'package:bnood/core/push/notification_settings_record.dart';
import 'package:bnood/core/api/api_response_parser.dart';
import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/core/api/auth_interceptor.dart';
import 'package:bnood/core/storage/session_store.dart';

class NotificationSettingsApi {
  NotificationSettingsApi({Dio? dio, SessionStore? sessionStore})
    : _dio = dio ?? createAppDio(sessionStore ?? SessionStore()),
      _ownsDio = dio == null;

  final Dio _dio;
  final bool _ownsDio;

  static const _prefix = '/v1/notification-settings';

  Map<String, dynamic> get _authenticatedExtra => {AuthInterceptor.authenticatedExtraKey: true};

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

  Future<NotificationSettingsRecord> getSettings() {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(_prefix, options: Options(extra: _authenticatedExtra));
      return ApiResponseParser.expectData(
        response,
        (json) => NotificationSettingsRecord.fromDataJson(json ?? const {}),
      );
    });
  }

  Future<NotificationSettingsRecord> patchSettings({
    bool? pushEnabled,
    bool? lowBalanceEnabled,
    int? lowBalanceAmountMinor,
  }) {
    final body =
        NotificationSettingsRecord(
          lowBalanceEnabled: lowBalanceEnabled ?? true,
          lowBalanceAmountMinor: lowBalanceAmountMinor ?? kDefaultLowBalanceAmountMinor,
        ).toPatchJson(
          pushEnabled: pushEnabled,
          lowBalanceEnabled: lowBalanceEnabled,
          lowBalanceAmountMinor: lowBalanceAmountMinor,
        );
    return _guard(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        _prefix,
        data: body,
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (json) => NotificationSettingsRecord.fromDataJson(json ?? const {}),
      );
    });
  }
}
