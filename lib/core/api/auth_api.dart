import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/session_store.dart';
import 'api_response_parser.dart';
import 'app_dio.dart';
import 'auth_api_exception.dart';
import 'auth_interceptor.dart';
import 'auth_login_result.dart';
import '../../features/auth/models/user.dart';

class AuthApi {
  AuthApi({
    Dio? dio,
    SessionStore? sessionStore,
  })  : _dio = dio ?? createAppDio(sessionStore ?? SessionStore()),
        _ownsDio = dio == null;

  final Dio _dio;
  final bool _ownsDio;

  static const _authPrefix = ApiConfig.subscriberAuthPrefix;

  Map<String, dynamic> get _authenticatedExtra => {
        AuthInterceptor.authenticatedExtraKey: true,
      };

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
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

  Future<RegistrationAccepted> register({
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_authPrefix/register',
        data: {
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      if (response.statusCode == 202) {
        return ApiResponseParser.expectData(response, RegistrationAccepted.fromJson);
      }
      throw ApiResponseParser.fromFailure(
        response,
        ApiResponseParser.decodeJson(response),
      );
    });
  }

  Future<RegistrationAccepted> resendRegistration(String registrationId) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_authPrefix/register/resend',
        data: {'registration_id': registrationId},
      );
      if (response.statusCode == 202) {
        return ApiResponseParser.expectData(response, RegistrationAccepted.fromJson);
      }
      throw ApiResponseParser.fromFailure(
        response,
        ApiResponseParser.decodeJson(response),
      );
    });
  }

  Future<AuthSessionPayload> verifyRegistration({
    required String registrationId,
    required String code,
  }) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_authPrefix/register/verify',
        data: {
          'registration_id': registrationId,
          'code': code,
        },
      );
      if (response.statusCode == 201) {
        return ApiResponseParser.expectData(response, AuthSessionPayload.fromJson);
      }
      throw ApiResponseParser.fromFailure(
        response,
        ApiResponseParser.decodeJson(response),
      );
    });
  }

  Future<LoginResult> login({
    required String phone,
    required String password,
  }) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_authPrefix/login',
        data: {
          'phone': phone,
          'password': password,
        },
      );
      final json = ApiResponseParser.decodeJson(response);
      final status = response.statusCode ?? 0;
      if (json['success'] != true) {
        throw ApiResponseParser.fromFailure(response, json);
      }
      final data = json['data'];
      if (data is! Map<String, dynamic>) {
        throw AuthApiException(
          statusCode: status,
          message: 'Unexpected response shape',
        );
      }
      if (status == 200) {
        return LoginResultSession(AuthSessionPayload.fromJson(data));
      }
      if (status == 202) {
        return LoginRegistrationChallenge(RegistrationAccepted.fromJson(data));
      }
      throw ApiResponseParser.fromFailure(response, json);
    });
  }

  Future<User> me() {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_authPrefix/me',
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (data) => User.fromJson(
          (data?['user'] as Map<String, dynamic>?) ?? data!,
        ),
      );
    });
  }

  Future<User> updateProfile({required String name}) {
    return _guard(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        '$_authPrefix/profile',
        data: {'name': name},
        options: Options(extra: _authenticatedExtra),
      );
      return ApiResponseParser.expectData(
        response,
        (data) => User.fromJson(
          (data?['user'] as Map<String, dynamic>?) ?? data!,
        ),
      );
    });
  }

  Future<void> logout() {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_authPrefix/logout',
        options: Options(extra: _authenticatedExtra),
      );
      ApiResponseParser.expectSuccess(response);
    });
  }

  Future<RecoveryAccepted> forgotPassword(String phone) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_authPrefix/forgot-password',
        data: {'phone': phone},
      );
      if (response.statusCode == 202) {
        return ApiResponseParser.expectData(response, RecoveryAccepted.fromJson);
      }
      throw ApiResponseParser.fromFailure(
        response,
        ApiResponseParser.decodeJson(response),
      );
    });
  }

  Future<ResetAuthorization> verifyForgotPassword({
    required String recoveryId,
    required String code,
  }) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_authPrefix/forgot-password/verify',
        data: {
          'recovery_id': recoveryId,
          'code': code,
        },
      );
      return ApiResponseParser.expectData(response, ResetAuthorization.fromJson);
    });
  }

  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_authPrefix/reset-password',
        data: {
          'reset_token': resetToken,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      ApiResponseParser.expectSuccess(response);
    });
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_authPrefix/change-password',
        data: {
          'current_password': currentPassword,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
        options: Options(extra: _authenticatedExtra),
      );
      ApiResponseParser.expectSuccess(response);
    });
  }

  void close() {
    if (_ownsDio) {
      _dio.close();
    }
  }
}

class RegistrationAccepted {
  const RegistrationAccepted({
    required this.registrationId,
    required this.expiresIn,
    required this.resendAfter,
  });

  final String registrationId;
  final int expiresIn;
  final int resendAfter;

  factory RegistrationAccepted.fromJson(Map<String, dynamic>? json) {
    return RegistrationAccepted(
      registrationId: json!['registration_id'] as String,
      expiresIn: json['expires_in'] as int,
      resendAfter: json['resend_after'] as int,
    );
  }
}

class RecoveryAccepted {
  const RecoveryAccepted({
    required this.recoveryId,
    required this.expiresIn,
    required this.resendAfter,
  });

  final String recoveryId;
  final int expiresIn;
  final int resendAfter;

  factory RecoveryAccepted.fromJson(Map<String, dynamic>? json) {
    return RecoveryAccepted(
      recoveryId: json!['recovery_id'] as String,
      expiresIn: json['expires_in'] as int,
      resendAfter: json['resend_after'] as int,
    );
  }
}

class ResetAuthorization {
  const ResetAuthorization({
    required this.resetToken,
    required this.expiresIn,
  });

  final String resetToken;
  final int expiresIn;

  factory ResetAuthorization.fromJson(Map<String, dynamic>? json) {
    return ResetAuthorization(
      resetToken: json!['reset_token'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }
}

class AuthSessionPayload {
  const AuthSessionPayload({
    required this.token,
    required this.user,
  });

  final String token;
  final User user;

  factory AuthSessionPayload.fromJson(Map<String, dynamic>? json) {
    return AuthSessionPayload(
      token: json!['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
