import 'package:bnood/core/network/api/app_dio.dart';
import 'package:bnood/core/network/api/auth_api_exception.dart';
import 'package:bnood/features/clients/data/clients_api.dart';
import 'package:bnood/features/clients/data/client_api_record.dart';
import 'package:bnood/features/clients/data/client_list_archive_filter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

ClientsApi _clientsApi(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
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

    test('parses engineer_basis_points from project', () {
      final record = ClientApiRecord.fromDataJson({
        'id': '01JCLIENT',
        'name': 'Ahmed',
        'phone': null,
        'archived_at': null,
        'created_at': '2026-11-09T10:00:00Z',
        'updated_at': '2026-11-09T10:00:00Z',
        'project': {
          'id': '01JPROJ',
          'name': 'Ahmed',
          'status': 'active',
          'engineer_basis_points': 750,
        },
        'balances': {'received': 10000, 'spent': 50000, 'remaining': 5000},
      });
      expect(record.project.engineerBasisPoints, 750);
    });

    test('parses live list row with null project and integer balances', () {
      final record = ClientApiRecord.fromDataJson({
        'id': '01m81qm4pyc2k7ne69yet9r02h',
        'name': 'د/ محمد محمود',
        'phone': '+201002003000',
        'archived_at': null,
        'created_at': '2026-11-22T13:37:41+00:00',
        'updated_at': '2026-11-22T13:37:41+00:00',
        'project': null,
        'projects': <dynamic>[],
        'balances': {'received': 0, 'spent': 0, 'remaining': 0},
      });
      expect(record.client.name, 'د/ محمد محمود');
      expect(record.project.id, '01m81qm4pyc2k7ne69yet9r02h:auto');
      expect(record.project.engineerBasisPoints, isNull);
      expect(record.balances?.remainingPiastres, 0);
    });

    test('falls back to projects list when project is null', () {
      final record = ClientApiRecord.fromDataJson({
        'id': 'c1',
        'name': 'Tower',
        'phone': null,
        'archived_at': null,
        'created_at': '2026-11-09T10:00:00Z',
        'updated_at': '2026-11-09T10:00:00Z',
        'project': null,
        'projects': [
          {
            'id': 'p-from-list',
            'name': 'Tower',
            'status': 'active',
            'engineer_basis_points': 250,
          },
        ],
      });
      expect(record.project.id, 'p-from-list');
      expect(record.project.engineerBasisPoints, 250);
    });

    test('null engineer_basis_points when omitted from project', () {
      final record = ClientApiRecord.fromDataJson({
        'id': '01JCLIENT',
        'name': 'Ahmed',
        'phone': null,
        'archived_at': null,
        'created_at': '2026-11-09T10:00:00Z',
        'updated_at': '2026-11-09T10:00:00Z',
        'project': {'id': '01JPROJ', 'name': 'Ahmed', 'status': 'active'},
      });
      expect(record.project.engineerBasisPoints, isNull);
    });
  });

  group('ClientsApi', () {
    test('list parses success envelope with null project rows', () async {
      final api = _clientsApi(
        (_) async => jsonResponse('''
{"success":true,"message":"ok","data":[
  {"id":"01m81qm4pyc2k7ne69yet9r02h","name":"د/ محمد محمود","phone":"+201002003000",
   "archived_at":null,"created_at":"2026-11-22T13:37:41+00:00","updated_at":"2026-11-22T13:37:41+00:00",
   "project":null,"projects":[],"balances":{"received":0,"spent":0,"remaining":0}}
],"meta":{"page":1,"per_page":50,"total":1}}'''),
      );
      final page = await api.listClients(status: ClientListArchiveFilter.active);
      expect(page.items, hasLength(1));
      expect(page.items.single.client.id, '01m81qm4pyc2k7ne69yet9r02h');
      api.close();
    });

    test('list sends status and bearer', () async {
      late RequestOptions captured;
      final api = _clientsApi((options) async {
        captured = options;
        return jsonResponse(
          '''
{"success":true,"message":"ok","data":[],"meta":{"page":1,"per_page":50,"total":0}}''',
        );
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
        throwsA(
          isA<AuthApiException>().having(
            (e) => e.isDuplicateName,
            'dup',
            isTrue,
          ),
        ),
      );
      api.close();
    });

    test('updateClient sends engineer_basis_points and clear null', () async {
      final bodies = <Map<String, dynamic>>[];
      final api = _clientsApi((options) async {
        if (options.method == 'PATCH') {
          bodies.add(Map<String, dynamic>.from(options.data as Map));
        }
        return jsonResponse('''
{"success":true,"message":"ok","data":{
  "id":"01JCLIENT","name":"Ahmed","phone":null,"archived_at":null,
  "created_at":"2026-11-09T10:00:00Z","updated_at":"2026-11-09T10:00:00Z",
  "project":{"id":"01JPROJ","name":"Ahmed","status":"active","engineer_basis_points":500}
}}''');
      });
      await api.updateClient(id: '01JCLIENT', engineerBasisPoints: 500);
      await api.updateClient(id: '01JCLIENT', clearEngineerBasisPoints: true);
      expect(bodies.length, 2);
      expect(bodies[0]['engineer_basis_points'], 500);
      expect(bodies[1].containsKey('engineer_basis_points'), isTrue);
      expect(bodies[1]['engineer_basis_points'], isNull);
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
        throwsA(
          isA<AuthApiException>().having(
            (e) => e.isClientHasActivity,
            'activity',
            isTrue,
          ),
        ),
      );
      api.close();
    });
  });
}
