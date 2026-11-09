import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/core/api/auth_interceptor.dart';
import 'package:bnood/core/api/clients_api.dart';
import 'package:bnood/core/clients/client_api_record.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

ClientsApi _clientsApi(Future<ResponseBody> Function(RequestOptions options) handler) {
  final dio = createAppDio(FakeSessionStore(token: 'tok'));
  dio.httpClientAdapter = ScriptedDioAdapter(handler);
  return ClientsApi(dio: dio);
}

void main() {
  group('ClientApiRecord', () {
    test('maps balances null without zero amounts', () {
      final record = ClientApiRecord.fromDataJson({
        'id': '01JCLIENT',
        'name': 'Ahmed',
        'phone': '+201012345678',
        'archived_at': null,
        'created_at': '2026-11-09T10:00:00Z',
        'updated_at': '2026-11-09T10:00:00Z',
        'project': {'id': '01JPROJ', 'name': 'Ahmed', 'status': 'active'},
        'balances': null,
      });
      expect(record.balances, isNull);
      expect(record.client.name, 'Ahmed');
      expect(record.project.id, '01JPROJ');
    });
  });

  group('ClientsApi', () {
    test('list sends status and bearer', () async {
      late RequestOptions captured;
      final api = _clientsApi((options) async {
        captured = options;
        return jsonResponse('''
{"success":true,"message":"ok","data":[],"meta":{"page":1,"per_page":50,"total":0}}''');
      });
      await api.listClients(status: ClientListArchiveFilter.active, q: 'ah');
      expect(captured.headers['Authorization'], 'Bearer tok');
      expect(captured.queryParameters['status'], 'active');
      expect(captured.queryParameters['q'], 'ah');
      api.close();
    });

    test('create maps duplicate_name', () async {
      final api = _clientsApi(
        (_) async => jsonResponse(
          '{"success":false,"message":"dup","code":"duplicate_name"}',
          statusCode: 409,
        ),
      );
      expect(
        () => api.createClient(name: 'Ahmed'),
        throwsA(isA<AuthApiException>().having((e) => e.isDuplicateName, 'dup', isTrue)),
      );
      api.close();
    });

    test('delete maps client_has_activity', () async {
      final api = _clientsApi(
        (_) async => jsonResponse(
          '{"success":false,"message":"busy","code":"client_has_activity"}',
          statusCode: 409,
        ),
      );
      expect(
        () => api.deleteClient('01J'),
        throwsA(isA<AuthApiException>().having((e) => e.isClientHasActivity, 'activity', isTrue)),
      );
      api.close();
    });
  });
}
