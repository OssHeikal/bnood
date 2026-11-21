import 'package:bnood/core/account/api_office_header.dart';
import 'package:bnood/core/network/api/app_dio.dart';
import 'package:bnood/core/network/api/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

void main() {
  tearDown(() => ApiOfficeHeader.syncOfficeId(null));

  test('authenticated personal omits X-Office-Id', () async {
    ApiOfficeHeader.syncOfficeId(null);
    final dio = createAppDio(FakeSessionStore(token: 'tok'));
    String? officeHeader;
    dio.httpClientAdapter = ScriptedDioAdapter((options) async {
      officeHeader = options.headers[ApiOfficeHeader.headerName] as String?;
      return ResponseBody.fromString('{"success":true,"data":{}}', 200);
    });

    await dio.get<dynamic>(
      '/v1/home',
      options: Options(extra: {AuthInterceptor.authenticatedExtraKey: true}),
    );

    expect(officeHeader, isNull);
  });

  test('authenticated office sends X-Office-Id', () async {
    const officeId = '01J9Z8XQ8K9M2N3P4R5S6T7V8W';
    ApiOfficeHeader.syncOfficeId(officeId);
    final dio = createAppDio(FakeSessionStore(token: 'tok'));
    String? officeHeader;
    dio.httpClientAdapter = ScriptedDioAdapter((options) async {
      officeHeader = options.headers[ApiOfficeHeader.headerName] as String?;
      return ResponseBody.fromString('{"success":true,"data":{}}', 200);
    });

    await dio.get<dynamic>(
      '/v1/home',
      options: Options(extra: {AuthInterceptor.authenticatedExtraKey: true}),
    );

    expect(officeHeader, officeId);
  });

  test('unauthenticated request omits X-Office-Id even when office selected', () async {
    ApiOfficeHeader.syncOfficeId('01J9Z8XQ8K9M2N3P4R5S6T7V8W');
    final dio = createAppDio(FakeSessionStore(token: 'tok'));
    String? officeHeader;
    dio.httpClientAdapter = ScriptedDioAdapter((options) async {
      officeHeader = options.headers[ApiOfficeHeader.headerName] as String?;
      return ResponseBody.fromString('{"success":true,"data":{}}', 200);
    });

    await dio.get<dynamic>('/v1/app/config');

    expect(officeHeader, isNull);
  });
}