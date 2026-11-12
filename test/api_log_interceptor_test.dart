import 'dart:typed_data';

import 'package:bnood/core/api/api_log_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/scripted_dio_adapter.dart';

void main() {
  test('pdf and image bodies log a byte count', () async {
    final lines = <String>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    dio.interceptors.add(
      ApiLogInterceptor(
        write: (message, {error, stackTrace}) => lines.add(message),
        verbose: true,
      ),
    );
    final bytes = Uint8List.fromList(List<int>.generate(180, (i) => (i + 80) % 256));
    dio.httpClientAdapter = ScriptedDioAdapter((_) async => pdfResponse(bytes));

    final response = await dio.get<List<int>>(
      '/v1/receipts/1',
      options: Options(responseType: ResponseType.bytes),
    );

    expect(response.data, bytes);
    final bodyLog = lines.last;
    expect(bodyLog, contains('(binary, 180 bytes)'));
    expect(bodyLog, isNot(contains('136,')));
    expect(bodyLog, isNot(contains('\n│   [')));
  });

  test('json error bodies stay readable', () async {
    final lines = <String>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    dio.interceptors.add(
      ApiLogInterceptor(
        write: (message, {error, stackTrace}) => lines.add(message),
        verbose: true,
      ),
    );
    dio.httpClientAdapter = ScriptedDioAdapter(
      (_) async => jsonResponse('{"success":false,"code":"not_found"}', statusCode: 404),
    );
    dio.options.validateStatus = (status) => status != null && status < 500;

    await dio.get<Map<String, dynamic>>('/v1/clients/1');

    expect(lines.last, contains('"success": false'));
    expect(lines.last, isNot(contains('(binary,')));
  });
}
