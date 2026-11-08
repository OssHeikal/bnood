import 'dart:convert';
import 'dart:io' show Platform;

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_response_parser.dart';
import 'subscriber_api_exception.dart';
import '../../features/auth/models/subscriber_user.dart';

class SubscriberAuthApi {
  SubscriberAuthApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Map<String, String> _headers({String? bearer}) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (bearer != null && bearer.isNotEmpty)
          'Authorization': 'Bearer $bearer',
      };

  String get _deviceName {
    try {
      return 'Bnood ${Platform.operatingSystem}';
    } catch (_) {
      return 'Bnood';
    }
  }

  Future<RegistrationAccepted> register({
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _client.post(
        _uri('${ApiConfig.subscriberAuthPrefix}/register'),
        headers: _headers(),
        body: jsonEncode({
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );
      if (response.statusCode == 202) {
        return ApiResponseParser.expectData(response, RegistrationAccepted.fromJson);
      }
      throw ApiResponseParser.fromFailure(
        response,
        ApiResponseParser.decodeJson(response),
      );
    } catch (e) {
      if (e is SubscriberApiException) rethrow;
      throw ApiResponseParser.transport(e);
    }
  }

  Future<RegistrationAccepted> resendRegistration(String registrationId) async {
    try {
      final response = await _client.post(
        _uri('${ApiConfig.subscriberAuthPrefix}/register/resend'),
        headers: _headers(),
        body: jsonEncode({'registration_id': registrationId}),
      );
      if (response.statusCode == 202) {
        return ApiResponseParser.expectData(response, RegistrationAccepted.fromJson);
      }
      throw ApiResponseParser.fromFailure(
        response,
        ApiResponseParser.decodeJson(response),
      );
    } catch (e) {
      if (e is SubscriberApiException) rethrow;
      throw ApiResponseParser.transport(e);
    }
  }

  Future<AuthSessionPayload> verifyRegistration({
    required String registrationId,
    required String code,
  }) async {
    try {
      final response = await _client.post(
        _uri('${ApiConfig.subscriberAuthPrefix}/register/verify'),
        headers: _headers(),
        body: jsonEncode({
          'registration_id': registrationId,
          'code': code,
          'device_name': _deviceName,
        }),
      );
      if (response.statusCode == 201) {
        return ApiResponseParser.expectData(response, AuthSessionPayload.fromJson);
      }
      throw ApiResponseParser.fromFailure(
        response,
        ApiResponseParser.decodeJson(response),
      );
    } catch (e) {
      if (e is SubscriberApiException) rethrow;
      throw ApiResponseParser.transport(e);
    }
  }

  Future<AuthSessionPayload> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        _uri('${ApiConfig.subscriberAuthPrefix}/login'),
        headers: _headers(),
        body: jsonEncode({
          'phone': phone,
          'password': password,
          'device_name': _deviceName,
        }),
      );
      return ApiResponseParser.expectData(response, AuthSessionPayload.fromJson);
    } catch (e) {
      if (e is SubscriberApiException) rethrow;
      throw ApiResponseParser.transport(e);
    }
  }

  Future<SubscriberUser> me(String bearer) async {
    try {
      final response = await _client.get(
        _uri('${ApiConfig.subscriberAuthPrefix}/me'),
        headers: _headers(bearer: bearer),
      );
      final user = ApiResponseParser.expectData(
        response,
        (data) => SubscriberUser.fromJson(
          (data?['user'] as Map<String, dynamic>?) ?? data!,
        ),
      );
      return user;
    } catch (e) {
      if (e is SubscriberApiException) rethrow;
      throw ApiResponseParser.transport(e);
    }
  }

  Future<void> logout(String bearer) async {
    try {
      final response = await _client.post(
        _uri('${ApiConfig.subscriberAuthPrefix}/logout'),
        headers: _headers(bearer: bearer),
      );
      ApiResponseParser.expectSuccess(response);
    } catch (e) {
      if (e is SubscriberApiException) rethrow;
      throw ApiResponseParser.transport(e);
    }
  }

  Future<RecoveryAccepted> forgotPassword(String phone) async {
    try {
      final response = await _client.post(
        _uri('${ApiConfig.subscriberAuthPrefix}/forgot-password'),
        headers: _headers(),
        body: jsonEncode({'phone': phone}),
      );
      if (response.statusCode == 202) {
        return ApiResponseParser.expectData(response, RecoveryAccepted.fromJson);
      }
      throw ApiResponseParser.fromFailure(
        response,
        ApiResponseParser.decodeJson(response),
      );
    } catch (e) {
      if (e is SubscriberApiException) rethrow;
      throw ApiResponseParser.transport(e);
    }
  }

  Future<ResetAuthorization> verifyForgotPassword({
    required String recoveryId,
    required String code,
  }) async {
    try {
      final response = await _client.post(
        _uri('${ApiConfig.subscriberAuthPrefix}/forgot-password/verify'),
        headers: _headers(),
        body: jsonEncode({
          'recovery_id': recoveryId,
          'code': code,
        }),
      );
      return ApiResponseParser.expectData(response, ResetAuthorization.fromJson);
    } catch (e) {
      if (e is SubscriberApiException) rethrow;
      throw ApiResponseParser.transport(e);
    }
  }

  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _client.post(
        _uri('${ApiConfig.subscriberAuthPrefix}/reset-password'),
        headers: _headers(),
        body: jsonEncode({
          'reset_token': resetToken,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );
      ApiResponseParser.expectSuccess(response);
    } catch (e) {
      if (e is SubscriberApiException) rethrow;
      throw ApiResponseParser.transport(e);
    }
  }

  Future<void> changePassword({
    required String bearer,
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _client.post(
        _uri('${ApiConfig.subscriberAuthPrefix}/change-password'),
        headers: _headers(bearer: bearer),
        body: jsonEncode({
          'current_password': currentPassword,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );
      ApiResponseParser.expectSuccess(response);
    } catch (e) {
      if (e is SubscriberApiException) rethrow;
      throw ApiResponseParser.transport(e);
    }
  }

  void close() => _client.close();
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
  final SubscriberUser user;

  factory AuthSessionPayload.fromJson(Map<String, dynamic>? json) {
    return AuthSessionPayload(
      token: json!['token'] as String,
      user: SubscriberUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
