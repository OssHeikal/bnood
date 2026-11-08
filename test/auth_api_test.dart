import 'package:bnood/core/api/auth_api.dart';
import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AuthApi', () {
    test('login maps invalid_credentials', () async {
      final client = MockClient((request) async {
        expect(request.url.path, endsWith('/v1/auth/login'));
        return http.Response(
          '{"success":false,"message":"bad","code":"invalid_credentials"}',
          401,
        );
      });
      final api = AuthApi(client: client);
      expect(
        () => api.login(phone: '01012345678', password: 'wrongpass1'),
        throwsA(isA<AuthApiException>().having((e) => e.isInvalidCredentials, 'invalid', isTrue)),
      );
      api.close();
    });

    test('verifyRegistration accepts 201 session payload', () async {
      final client = MockClient((request) async {
        return http.Response(
          '''
{"success":true,"message":"verified","data":{
  "token":"tok_abc",
  "user":{"id":"usr_1","phone":"+201012345678","phone_verified_at":"2025-01-01T00:00:00.000000Z"}
}}''',
          201,
        );
      });
      final api = AuthApi(client: client);
      final session = await api.verifyRegistration(
        registrationId: 'reg_1',
        code: '1111',
      );
      expect(session.token, 'tok_abc');
      expect(session.user.id, 'usr_1');
      api.close();
    });

    test('forgot password verify returns reset_token without login', () async {
      final client = MockClient((request) async {
        return http.Response(
          '{"success":true,"message":"ok","data":{"reset_token":"rst_1","expires_in":300}}',
          200,
        );
      });
      final api = AuthApi(client: client);
      final auth = await api.verifyForgotPassword(recoveryId: 'rec_1', code: '1111');
      expect(auth.resetToken, 'rst_1');
      api.close();
    });
  });
}
