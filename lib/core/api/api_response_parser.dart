import 'dart:convert';

import 'package:http/http.dart' as http;

import 'subscriber_api_exception.dart';

abstract final class ApiResponseParser {
  static Map<String, dynamic> decodeJson(http.Response response) {
    final body = response.body;
    if (body.isEmpty) return const {};
    return jsonDecode(body) as Map<String, dynamic>;
  }

  static T expectData<T>(
    http.Response response,
    T Function(Map<String, dynamic>? data) map,
  ) {
    final json = decodeJson(response);
    final success = json['success'] == true;
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        success) {
      final data = json['data'];
      if (data == null) {
        return map(null);
      }
      if (data is Map<String, dynamic>) {
        return map(data);
      }
      throw SubscriberApiException(
        statusCode: response.statusCode,
        message: 'Unexpected response shape',
      );
    }
    throw fromFailure(response, json);
  }

  static void expectSuccess(http.Response response) {
    final json = decodeJson(response);
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        json['success'] == true) {
      return;
    }
    throw fromFailure(response, json);
  }

  static SubscriberApiException fromFailure(
    http.Response response,
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
    return SubscriberApiException(
      statusCode: response.statusCode,
      message: message,
      code: code,
      fieldErrors: fieldErrors,
    );
  }

  static SubscriberApiException transport(Object error) {
    return SubscriberApiException(
      statusCode: 0,
      message: 'Network request failed',
      code: 'network',
    );
  }
}
