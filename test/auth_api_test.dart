import 'package:bnood/core/api/api_log_interceptor.dart';
import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/auth_api.dart';
import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/core/api/auth_login_result.dart';
import 'package:bnood/core/api/auth_interceptor.dart';
import 'package:bnood/core/config/api_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

AuthApi _apiWithAdapter(FakeSessionStore store, Future<ResponseBody> Function(RequestOptions options) handler) {
  final dio = createAppDio(store);
  dio.httpClientAdapter = ScriptedDioAdapter(handler);
  return AuthApi(dio: dio);
}

void main() {
  group('AuthApi', () {
    test('login maps invalid_credentials', () async {
      final api = _apiWithAdapter(
        FakeSessionStore(),
        (_) async => jsonResponse('{"success":false,"message":"bad","code":"invalid_credentials"}', statusCode: 401),
      );
      expect(
        () => api.login(phone: '01012345678', password: 'wrongpass1'),
        throwsA(isA<AuthApiException>().having((e) => e.isInvalidCredentials, 'invalid', isTrue)),
      );
      api.close();
    });

    test('login and verify payloads omit device_name', () async {
      final api = _apiWithAdapter(FakeSessionStore(), (options) async {
        final data = options.data as Map<String, dynamic>?;
        expect(data?.containsKey('device_name'), isFalse);
        if (options.method == 'POST' && options.path.endsWith('/login')) {
          return jsonResponse('''
{"success":true,"message":"ok","data":{
  "token":"new_tok",
  "user":{"id":"u1","phone":"+201012345678","name":"Eng","phone_verified_at":"2025-01-01T00:00:00Z"}
}}''');
        }
        return jsonResponse('''
{"success":true,"message":"verified","data":{
  "token":"tok_abc",
  "user":{"id":"usr_1","phone":"+201012345678","name":null,"phone_verified_at":"2025-01-01T00:00:00.000000Z"}
}}''', statusCode: 201);
      });
      final loginResult = await api.login(phone: '01012345678', password: 'password123');
      expect(loginResult, isA<LoginResultSession>());
      await api.verifyRegistration(registrationId: 'reg_1', code: '111111');
      api.close();
    });

    test('updateProfile PATCH sends trimmed name', () async {
      final api = _apiWithAdapter(FakeSessionStore(token: 'tok'), (options) async {
        expect(options.method, 'PATCH');
        expect(options.path.endsWith('/profile'), isTrue);
        expect((options.data as Map)['name'], 'Osama');
        return jsonResponse('''
{"success":true,"message":"ok","data":{
  "user":{"id":"u1","phone":"+201012345678","name":"Osama","phone_verified_at":"2025-01-01T00:00:00Z"}
}}''');
      });
      final user = await api.updateProfile(name: 'Osama');
      expect(user.name, 'Osama');
      api.close();
    });

    test('verifyRegistration accepts 201 session payload', () async {
      final api = _apiWithAdapter(
        FakeSessionStore(),
        (_) async => jsonResponse('''
{"success":true,"message":"verified","data":{
  "token":"tok_abc",
  "user":{"id":"usr_1","phone":"+201012345678","phone_verified_at":"2025-01-01T00:00:00.000000Z"}
}}''', statusCode: 201),
      );
      final session = await api.verifyRegistration(registrationId: 'reg_1', code: '111111');
      expect(session.token, 'tok_abc');
      expect(session.user.id, 'usr_1');
      api.close();
    });

    test('forgot password verify returns reset_token without login', () async {
      final api = _apiWithAdapter(
        FakeSessionStore(),
        (_) async => jsonResponse('{"success":true,"message":"ok","data":{"reset_token":"rst_1","expires_in":300}}'),
      );
      final auth = await api.verifyForgotPassword(recoveryId: 'rec_1', code: '111111');
      expect(auth.resetToken, 'rst_1');
      api.close();
    });

    test('me sends Bearer from store', () async {
      final api = _apiWithAdapter(FakeSessionStore(token: 'stored_tok'), (options) async {
        expect(options.headers['Authorization'], 'Bearer stored_tok');
        return jsonResponse('''
{"success":true,"message":"ok","data":{
  "user":{"id":"u1","phone":"+201012345678","phone_verified_at":"2025-01-01T00:00:00Z"}
}}''');
      });
      final user = await api.me();
      expect(user.id, 'u1');
      api.close();
    });

    test('login does not send Authorization when store has token', () async {
      final api = _apiWithAdapter(FakeSessionStore(token: 'existing'), (options) async {
        expect(options.headers.containsKey('Authorization'), isFalse);
        return jsonResponse('''
{"success":true,"message":"ok","data":{
  "token":"new_tok",
  "user":{"id":"u1","phone":"+201012345678","phone_verified_at":"2025-01-01T00:00:00Z"}
}}''');
      });
      final result = await api.login(phone: '01012345678', password: 'password123');
      expect(result, isA<LoginResultSession>());
      api.close();
    });

    test('me without token rejects before network', () async {
      final api = _apiWithAdapter(FakeSessionStore(), (_) async {
        fail('fetch should not run');
        // return jsonResponse('{}');
      });
      expect(
        () => api.me(),
        throwsA(
          isA<AuthApiException>()
              .having((e) => e.statusCode, 'status', 401)
              .having((e) => e.code, 'code', 'unauthorized'),
        ),
      );
      api.close();
    });

    test('failed login emits error log after auth interceptor', () async {
      final logLines = <String>[];
      final store = FakeSessionStore();
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          headers: {Headers.acceptHeader: 'application/json'},
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
      );
      dio.interceptors.add(AuthInterceptor(store));
      dio.interceptors.add(
        ApiLogInterceptor(write: (message, {error, stackTrace}) => logLines.add(message), verbose: true),
      );
      dio.httpClientAdapter = ScriptedDioAdapter(
        (_) async => jsonResponse('{"success":false,"message":"bad","code":"invalid_credentials"}', statusCode: 401),
      );
      final api = AuthApi(dio: dio);
      await expectLater(
        () => api.login(phone: '01012345678', password: 'wrongpass1'),
        throwsA(isA<AuthApiException>()),
      );
      expect(logLines.any((line) => line.contains('API ✕ POST')), isTrue);
      expect(logLines.any((line) => line.contains('Response body:')), isTrue);
      expect(logLines.any((line) => line.contains('invalid_credentials')), isTrue);
      api.close();
    });

    test('network failure maps to isNetwork', () async {
      final api = _apiWithAdapter(FakeSessionStore(), (_) async => throw Exception('socket'));
      expect(
        () => api.login(phone: '01012345678', password: 'password123'),
        throwsA(
          isA<AuthApiException>()
              .having((e) => e.isNetwork, 'network', isTrue)
              .having((e) => e.message, 'message', isNot(contains('socket'))),
        ),
      );
      api.close();
    });
  });
}
