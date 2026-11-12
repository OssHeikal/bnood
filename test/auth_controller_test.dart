import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/auth_api.dart';
import 'package:bnood/core/api/auth_api_providers.dart';
import 'package:bnood/core/storage/session_store.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_login_outcome.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:dio/dio.dart';
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
  group('AuthController', () {
    test('wrong login does not clear existing token', () async {
      final store = FakeSessionStore(token: 'existing');
      final container = ProviderContainer(
        overrides: [
          sessionStoreProvider.overrideWithValue(store),
          authApiProvider.overrideWithValue(
            _apiForTest(
              store,
              (_) async => jsonResponse(
                '{"success":false,"message":"bad","code":"invalid_credentials"}',
                statusCode: 401,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final outcome = await container.read(authControllerProvider.notifier).login(
            phone: '01012345678',
            password: 'wrongpass1',
          );
      expect(outcome, isA<LoginOutcomeFailed>());
      expect(await store.readToken(), 'existing');
      expect(container.read(authControllerProvider).isAuthenticated, isFalse);
    });

    test('bootstrap 401 clears token', () async {
      final store = FakeSessionStore(token: 'stale');
      final container = ProviderContainer(
        overrides: [
          sessionStoreProvider.overrideWithValue(store),
          authApiProvider.overrideWithValue(
            _apiForTest(
              store,
              (_) async => jsonResponse(
                '{"success":false,"message":"Unauthenticated"}',
                statusCode: 401,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.notifier).bootstrapFromStoredSession();
      expect(await store.readToken(), isNull);
      expect(
        container.read(authControllerProvider).bootstrapStatus,
        AuthBootstrapStatus.unauthenticated,
      );
    });

    test('bootstrap network error retains token', () async {
      final store = FakeSessionStore(token: 'keep');
      final container = ProviderContainer(
        overrides: [
          sessionStoreProvider.overrideWithValue(store),
          authApiProvider.overrideWithValue(
            _apiForTest(
              store,
              (_) async => throw Exception('offline'),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.notifier).bootstrapFromStoredSession();
      expect(await store.readToken(), 'keep');
      expect(
        container.read(authControllerProvider).bootstrapStatus,
        AuthBootstrapStatus.bootstrapNetworkError,
      );
    });

    test('verify registration persists token securely', () async {
      final store = FakeSessionStore();
      final container = ProviderContainer(
        overrides: [
          sessionStoreProvider.overrideWithValue(store),
          authApiProvider.overrideWithValue(
            _apiForTest(
              store,
              (options) async {
                if (options.path.endsWith('/register') &&
                    !options.path.contains('verify')) {
                  return jsonResponse(
                    '{"success":true,"data":{"registration_id":"reg_1","expires_in":600,"resend_after":60}}',
                    statusCode: 202,
                  );
                }
                return jsonResponse(
                  '''
{"success":true,"message":"ok","data":{
  "token":"tok_new",
  "user":{"id":"u1","phone":"+201012345678","phone_verified_at":"2025-01-01T00:00:00Z"}
}}''',
                  statusCode: 201,
                );
              },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authControllerProvider.notifier);
      await notifier.register(
        phone: '01012345678',
        password: 'password123',
        passwordConfirmation: 'password123',
      );
      final err = await notifier.verifyRegistration('111111');
      expect(err, isNull);
      expect(await store.readToken(), 'tok_new');
      expect(container.read(authControllerProvider).isAuthenticated, isTrue);
    });

    test('adoptSessionForTest does not expose token in state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(authControllerProvider.notifier).adoptSessionForTest(
            const User(id: 'u1', phone: '+201012345678', name: 'Eng'),
          );
      expect(container.read(authControllerProvider).user?.phone, '+201012345678');
    });

    test('saveProfileName updates user on success', () async {
      final store = FakeSessionStore(token: 'tok');
      final container = ProviderContainer(
        overrides: [
          sessionStoreProvider.overrideWithValue(store),
          authApiProvider.overrideWithValue(
            _apiForTest(
              store,
              (options) async {
                expect(options.method, 'PATCH');
                return jsonResponse(
                  '''
{"success":true,"message":"ok","data":{
  "user":{"id":"u1","phone":"+201012345678","name":"Osama","phone_verified_at":"2025-01-01T00:00:00Z"}
}}''',
                );
              },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.read(authControllerProvider.notifier).adoptSessionForTest(
            const User(id: 'u1', phone: '+201012345678'),
          );
      final err =
          await container.read(authControllerProvider.notifier).saveProfileName('Osama');
      expect(err, isNull);
      expect(container.read(authControllerProvider).user?.hasCompleteName, isTrue);
    });
  });
}
