import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/auth_api.dart';
import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/core/api/auth_api_providers.dart';
import 'package:bnood/core/api/auth_login_result.dart';
import 'package:bnood/core/storage/session_store.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_form_ui.dart';
import 'package:bnood/features/auth/auth_form_utils.dart';
import 'package:bnood/features/auth/auth_login_outcome.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

AuthApi _apiForTest(
  FakeSessionStore store,
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = createAppDio(store);
  dio.httpClientAdapter = ScriptedDioAdapter(handler);
  return AuthApi(dio: dio);
}

void main() {
  group('AuthApi account state', () {
    test('register maps account_exists on 409', () async {
      final api = _apiWithAdapter(
        FakeSessionStore(),
        (_) async => jsonResponse(
          '''
{"success":false,"message":"This phone is already linked to an account.","code":"account_exists"}
''',
          statusCode: 409,
        ),
      );
      expect(
        () => api.register(
          phone: '01012345678',
          password: 'password123',
          passwordConfirmation: 'password123',
        ),
        throwsA(
          isA<AuthApiException>()
              .having((e) => e.isAccountExists, 'account_exists', isTrue)
              .having((e) => e.statusCode, 'status', 409),
        ),
      );
      api.close();
    });

    test('login 200 returns session result', () async {
      final api = _apiWithAdapter(
        FakeSessionStore(),
        (_) async => jsonResponse(
          '''
{"success":true,"message":"ok","data":{
  "token":"tok",
  "user":{"id":"u1","phone":"+201012345678","name":"Eng","phone_verified_at":"2025-01-01T00:00:00Z"}
}}''',
          statusCode: 200,
        ),
      );
      final result = await api.login(phone: '01012345678', password: 'password123');
      expect(result, isA<LoginResultSession>());
      final session = (result as LoginResultSession).session;
      expect(session.token, 'tok');
      api.close();
    });

    test('login 202 returns registration challenge without token fields', () async {
      final api = _apiWithAdapter(
        FakeSessionStore(),
        (_) async => jsonResponse(
          '''
{"success":true,"message":"Registration started.","data":{
  "registration_id":"reg_ulid",
  "expires_in":600,
  "resend_after":60
}}''',
          statusCode: 202,
        ),
      );
      final result = await api.login(phone: '01012345678', password: 'password123');
      expect(result, isA<LoginRegistrationChallenge>());
      final challenge = (result as LoginRegistrationChallenge).challenge;
      expect(challenge.registrationId, 'reg_ulid');
      api.close();
    });
  });

  group('AuthController login challenge', () {
    test('login 202 sets pending registration without token', () async {
      final store = FakeSessionStore(token: 'existing');
      final container = ProviderContainer(
        overrides: [
          sessionStoreProvider.overrideWithValue(store),
          authApiProvider.overrideWithValue(
            _apiForTest(
              store,
              (_) async => jsonResponse(
                '''
{"success":true,"message":"Registration started.","data":{
  "registration_id":"reg_1",
  "expires_in":600,
  "resend_after":45
}}''',
                statusCode: 202,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final outcome = await container.read(authControllerProvider.notifier).login(
            phone: '01012345678',
            password: 'password123',
          );
      expect(outcome, isA<LoginOutcomeRegistrationChallenge>());
      expect(await store.readToken(), 'existing');
      expect(container.read(authControllerProvider).isAuthenticated, isFalse);
      expect(
        container.read(authControllerProvider).pendingRegistration?.registrationId,
        'reg_1',
      );
    });
  });

  group('Login phone prefill', () {
    test('takePhone returns value once', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(loginPhonePrefillProvider.notifier).setPhone('01012345678');
      expect(container.read(loginPhonePrefillProvider.notifier).takePhone(), '01012345678');
      expect(container.read(loginPhonePrefillProvider), isNull);
    });
  });

  group('OTP length', () {
    test('verification code requires exactly six digits', () {
      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(validateVerificationCode(l10n, '111111'), isNull);
      expect(validateVerificationCode(l10n, '11111'), isNotNull);
      expect(validateVerificationCode(l10n, '1111111'), isNotNull);
      expect(validateVerificationCode(l10n, '12ab34'), isNotNull);
    });
  });
}

AuthApi _apiWithAdapter(
  FakeSessionStore store,
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  return _apiForTest(store, handler);
}
