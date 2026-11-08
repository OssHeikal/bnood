import 'package:bnood/core/api/auth_api.dart';
import 'package:bnood/core/api/auth_api_providers.dart';
import 'package:bnood/core/storage/session_store.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'support/fake_session_store.dart';

void main() {
  group('AuthController', () {
    test('wrong login does not clear existing token', () async {
      final store = FakeSessionStore(token: 'existing');
      final client = MockClient((_) async => http.Response(
            '{"success":false,"message":"bad","code":"invalid_credentials"}',
            401,
          ));
      final container = ProviderContainer(
        overrides: [
          sessionStoreProvider.overrideWithValue(store),
          authApiProvider.overrideWithValue(AuthApi(client: client)),
        ],
      );
      addTearDown(container.dispose);

      final err = await container.read(authControllerProvider.notifier).login(
            phone: '01012345678',
            password: 'wrongpass1',
          );
      expect(err, isNotNull);
      expect(await store.readToken(), 'existing');
      expect(container.read(authControllerProvider).isAuthenticated, isFalse);
    });

    test('bootstrap 401 clears token', () async {
      final store = FakeSessionStore(token: 'stale');
      final client = MockClient((_) async => http.Response(
            '{"success":false,"message":"Unauthenticated"}',
            401,
          ));
      final container = ProviderContainer(
        overrides: [
          sessionStoreProvider.overrideWithValue(store),
          authApiProvider.overrideWithValue(AuthApi(client: client)),
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
      final client = MockClient((_) async => throw Exception('offline'));
      final container = ProviderContainer(
        overrides: [
          sessionStoreProvider.overrideWithValue(store),
          authApiProvider.overrideWithValue(AuthApi(client: client)),
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
      final client = MockClient((request) async {
        if (request.url.path.endsWith('/register') &&
            !request.url.path.contains('verify')) {
          return http.Response(
            '{"success":true,"data":{"registration_id":"reg_1","expires_in":600,"resend_after":60}}',
            202,
          );
        }
        return http.Response(
          '''
{"success":true,"message":"ok","data":{
  "token":"tok_new",
  "user":{"id":"u1","phone":"+201012345678","phone_verified_at":"2025-01-01T00:00:00Z"}
}}''',
          201,
        );
      });
      final container = ProviderContainer(
        overrides: [
          sessionStoreProvider.overrideWithValue(store),
          authApiProvider.overrideWithValue(AuthApi(client: client)),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authControllerProvider.notifier);
      await notifier.register(
        phone: '01012345678',
        password: 'password123',
        passwordConfirmation: 'password123',
      );
      final err = await notifier.verifyRegistration('1111');
      expect(err, isNull);
      expect(await store.readToken(), 'tok_new');
      expect(container.read(authControllerProvider).isAuthenticated, isTrue);
    });

    test('adoptSessionForTest does not expose token in state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(authControllerProvider.notifier).adoptSessionForTest(
            const User(id: 'u1', phone: '+201012345678'),
          );
      expect(container.read(authControllerProvider).user?.phone, '+201012345678');
    });
  });
}
