import 'package:bnood/core/api/api_response_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

Response<dynamic> _response({required dynamic data, required int statusCode}) {
  return Response(
    requestOptions: RequestOptions(path: '/'),
    data: data,
    statusCode: statusCode,
  );
}

void main() {
  group('ApiResponseParser', () {
    test('expectData parses success envelope', () {
      final response = _response(
        statusCode: 202,
        data: {
          'success': true,
          'message': 'ok',
          'data': {'registration_id': 'reg_1', 'expires_in': 600, 'resend_after': 60},
        },
      );
      final data = ApiResponseParser.expectData(response, (json) => json!['registration_id'] as String);
      expect(data, 'reg_1');
    });

    test('fromFailure maps 422 field errors', () {
      final response = _response(
        statusCode: 422,
        data: {
          'success': false,
          'message': 'Validation failed',
          'errors': {
            'phone': ['bad phone'],
          },
        },
      );
      final json = ApiResponseParser.decodeJson(response);
      final err = ApiResponseParser.fromFailure(response, json);
      expect(err.statusCode, 422);
      expect(err.fieldErrors?['phone']?.single, 'bad phone');
    });

    test('fromFailure maps throttle code', () {
      final response = _response(statusCode: 429, data: {'success': false, 'message': 'slow', 'code': 'throttled'});
      final json = ApiResponseParser.decodeJson(response);
      final err = ApiResponseParser.fromFailure(response, json);
      expect(err.isThrottled, isTrue);
    });

    test('transport wraps network failures', () {
      final err = ApiResponseParser.transport(Exception('socket'));
      expect(err.isNetwork, isTrue);
      expect(err.message, isNot(contains('socket')));
    });

    test('fromDio maps bad response', () {
      final response = _response(
        statusCode: 401,
        data: {'success': false, 'message': 'bad', 'code': 'invalid_credentials'},
      );
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/login'),
        response: response,
        type: DioExceptionType.badResponse,
      );
      final err = ApiResponseParser.fromDio(dioErr);
      expect(err.isInvalidCredentials, isTrue);
    });

    test('fromDio maps connection error to network', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/me'),
        type: DioExceptionType.connectionError,
        message: 'offline',
      );
      final err = ApiResponseParser.fromDio(dioErr);
      expect(err.isNetwork, isTrue);
    });
  });
}
