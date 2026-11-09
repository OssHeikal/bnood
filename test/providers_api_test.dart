import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/core/api/providers_api.dart';
import 'package:bnood/core/providers_api/app_provider_record.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

ProvidersApi _providersApi(Future<ResponseBody> Function(RequestOptions options) handler) {
  final dio = createAppDio(FakeSessionStore(token: 'tok'));
  dio.httpClientAdapter = ScriptedDioAdapter(handler);
  return ProvidersApi(dio: dio);
}

void main() {
  group('AppProvider', () {
    test('fromDataJson maps supplier type', () {
      final provider = AppProvider.fromDataJson({
        'id': '01JPROV',
        'name': 'Steel Co',
        'phone': '+201012345678',
        'type': 'supplier',
        'created_at': '2026-11-09T10:00:00Z',
        'updated_at': '2026-11-09T10:00:00Z',
      });
      expect(provider.type, AppProviderType.supplier);
      expect(provider.phone, '+201012345678');
    });

    test('craftsman parses paid remaining clients_count', () {
      final provider = AppProvider.fromDataJson({
        'id': '01JCRAFT',
        'name': 'Ali',
        'phone': null,
        'type': 'craftsman',
        'paid': 500_000,
        'remaining': 250_000,
        'clients_count': 2,
        'created_at': '2026-11-09T10:00:00Z',
        'updated_at': '2026-11-09T10:00:00Z',
      });
      expect(provider.paidMinor, 500_000);
      expect(provider.remainingMinor, 250_000);
      expect(provider.clientsCount, 2);
    });

    test('supplier ignores craftsman-only fields', () {
      final provider = AppProvider.fromDataJson({
        'id': '01JSUP',
        'name': 'Steel',
        'phone': null,
        'type': 'supplier',
        'created_at': '2026-11-09T10:00:00Z',
        'updated_at': '2026-11-09T10:00:00Z',
      });
      expect(provider.paidMinor, isNull);
      expect(provider.clientsCount, isNull);
    });
  });

  group('ProvidersApi', () {
    test('list sends bearer, type filter, and q', () async {
      late RequestOptions captured;
      final api = _providersApi((options) async {
        captured = options;
        return jsonResponse(
          '{"success":true,"data":[],"meta":{"page":1,"per_page":50,"total":0}}',
        );
      });
      await api.listProviders(q: 'ali', type: AppProviderType.craftsman, page: 2);
      expect(captured.headers['Authorization'], 'Bearer tok');
      expect(captured.queryParameters['q'], 'ali');
      expect(captured.queryParameters['type'], 'craftsman');
      expect(captured.queryParameters['page'], 2);
      api.close();
    });

    test('create omits phone when empty', () async {
      late Object? body;
      final api = _providersApi((options) async {
        body = options.data;
        return jsonResponse(
          '{"success":true,"data":{"id":"01J","name":"X","phone":null,"type":"supplier","created_at":"2026-11-09T10:00:00Z","updated_at":"2026-11-09T10:00:00Z"}}',
        );
      });
      await api.createProvider(name: 'X', type: AppProviderType.supplier);
      expect(body, isA<Map>());
      expect((body! as Map).containsKey('phone'), isFalse);
      api.close();
    });

    test('patch body excludes type', () async {
      late Object? body;
      final api = _providersApi((options) async {
        body = options.data;
        return jsonResponse(
          '{"success":true,"data":{"id":"01J","name":"Y","phone":null,"type":"supplier","created_at":"2026-11-09T10:00:00Z","updated_at":"2026-11-09T10:00:00Z"}}',
        );
      });
      await api.updateProvider(id: '01J', name: 'Y');
      expect((body! as Map).containsKey('type'), isFalse);
      api.close();
    });

    test('duplicate_phone on 422', () async {
      final api = _providersApi(
        (_) async => jsonResponse(
          '{"success":false,"message":"dup","code":"duplicate_phone"}',
          statusCode: 422,
        ),
      );
      expect(
        () => api.createProvider(name: 'X', type: AppProviderType.supplier, phone: '+2010'),
        throwsA(isA<AuthApiException>().having((e) => e.isDuplicatePhone, 'dup', isTrue)),
      );
      api.close();
    });
  });
}
