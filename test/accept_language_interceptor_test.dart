import 'package:bnood/core/api/api_accept_language.dart';
import 'package:bnood/core/api/app_dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

void main() {
  test('Accept-Language header follows synced locale on every request', () async {
    ApiAcceptLanguage.syncLocale(const Locale('ar'));
    final dio = createAppDio(FakeSessionStore());
    late String? acceptLanguage;
    dio.httpClientAdapter = ScriptedDioAdapter((options) async {
      acceptLanguage = options.headers['Accept-Language'] as String?;
      return ResponseBody.fromString('{"success":true,"data":{}}', 200);
    });

    await dio.get<dynamic>('/v1/ping');

    expect(acceptLanguage, 'ar');

    ApiAcceptLanguage.syncLocale(const Locale('en'));
    await dio.get<dynamic>('/v1/ping');
    expect(acceptLanguage, 'en');
  });
}
