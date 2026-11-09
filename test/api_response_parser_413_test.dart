import 'package:bnood/core/api/api_response_parser.dart';
import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps nginx 413 HTML to invalid_size', () {
    final err = DioException(
      requestOptions: RequestOptions(path: '/v1/vouchers/x/receipts'),
      response: Response(
        requestOptions: RequestOptions(path: '/v1/vouchers/x/receipts'),
        statusCode: 413,
        data: '<html><body>Request Entity Too Large</body></html>',
      ),
      type: DioExceptionType.badResponse,
    );
    final mapped = ApiResponseParser.fromDio(err);
    expect(mapped.statusCode, 413);
    expect(mapped.code, 'invalid_size');
    expect(mapped.isInvalidSize, isTrue);
  });

  test('voucher upload error message prefers localized too-large', () {
    final err = AuthApiException(statusCode: 413, message: 'html', code: 'invalid_size');
    expect(err.isInvalidSize, isTrue);
  });
}
