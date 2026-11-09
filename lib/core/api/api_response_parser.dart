import 'dart:convert';

import 'package:dio/dio.dart';

import 'auth_api_exception.dart';

abstract final class ApiResponseParser {
  static Map<String, dynamic> decodeJson(Response<dynamic> response) {
    final data = response.data;
    if (data == null) return const {};
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      if (data.isEmpty) return const {};
      return jsonDecode(data) as Map<String, dynamic>;
    }
    throw AuthApiException(
      statusCode: response.statusCode ?? 0,
      message: 'Unexpected response shape',
    );
  }

  static T expectData<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>? data) map,
  ) {
    final json = decodeJson(response);
    final success = json['success'] == true;
    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300 && success) {
      final data = json['data'];
      if (data == null) {
        return map(null);
      }
      if (data is Map<String, dynamic>) {
        return map(data);
      }
      throw AuthApiException(
        statusCode: status,
        message: 'Unexpected response shape',
      );
    }
    throw fromFailure(response, json);
  }

  static void expectSuccess(Response<dynamic> response) {
    final json = decodeJson(response);
    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300 && json['success'] == true) {
      return;
    }
    throw fromFailure(response, json);
  }

  static AuthApiException fromFailure(
    Response<dynamic> response,
    Map<String, dynamic> json,
  ) {
    final message = (json['message'] as String?) ?? 'Request failed';
    final code = json['code'] as String?;
    Map<String, List<String>>? fieldErrors;
    final errors = json['errors'];
    if (errors is Map<String, dynamic>) {
      fieldErrors = errors.map(
        (key, value) => MapEntry(
          key,
          (value is List)
              ? value.map((e) => e.toString()).toList()
              : [value.toString()],
        ),
      );
    }
    return AuthApiException(
      statusCode: response.statusCode ?? 0,
      message: message,
      code: code,
      fieldErrors: fieldErrors,
    );
  }

  static AuthApiException transport(Object error) {
    return AuthApiException(
      statusCode: 0,
      message: 'Network request failed',
      code: 'network',
    );
  }

  static AuthApiException fromDio(DioException err) {
    final response = err.response;
    if (response != null) {
      final status = response.statusCode ?? 0;
      if (status == 413) {
        return AuthApiException(
          statusCode: 413,
          code: 'invalid_size',
          message: 'Request entity too large',
        );
      }
      try {
        final json = decodeJson(response);
        return fromFailure(response, json);
      } catch (_) {
        return AuthApiException(
          statusCode: status,
          message: 'Request failed',
        );
      }
    }
    return transport(err);
  }
}
