import 'package:bnood/core/api/api_response_parser.dart';
import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('ApiResponseParser', () {
    test('expectData parses success envelope', () {
      final response = http.Response(
        '{"success":true,"message":"ok","data":{"registration_id":"reg_1","expires_in":600,"resend_after":60}}',
        202,
      );
      final data = ApiResponseParser.expectData(
        response,
        (json) => json!['registration_id'] as String,
      );
      expect(data, 'reg_1');
    });

    test('fromFailure maps 422 field errors', () {
      final response = http.Response(
        '{"success":false,"message":"Validation failed","errors":{"phone":["bad phone"]}}',
        422,
      );
      final json = ApiResponseParser.decodeJson(response);
      final err = ApiResponseParser.fromFailure(response, json);
      expect(err.statusCode, 422);
      expect(err.fieldErrors?['phone']?.single, 'bad phone');
    });

    test('fromFailure maps throttle code', () {
      final response = http.Response(
        '{"success":false,"message":"slow","code":"throttled"}',
        429,
      );
      final json = ApiResponseParser.decodeJson(response);
      final err = ApiResponseParser.fromFailure(response, json);
      expect(err.isThrottled, isTrue);
    });

    test('transport wraps network failures', () {
      final err = ApiResponseParser.transport(Exception('socket'));
      expect(err.isNetwork, isTrue);
      expect(err.message, isNot(contains('socket')));
    });
  });
}
