import 'package:bnood/core/network/api/app_dio.dart';
import 'package:bnood/features/clients/data/office_clients_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

void main() {
  test('getClient calls /v1/clients/:id/identity', () async {
    Uri? captured;
    final api = OfficeClientsApi(
      dio: createAppDio(FakeSessionStore(token: 'tok'))
        ..httpClientAdapter = ScriptedDioAdapter((options) async {
          captured = options.uri;
          return ResponseBody.fromString(
            '''
{
  "success": true,
  "data": {
    "client": {
      "id": "01JCLIENT",
      "name": "Ahmed",
      "phone": "+2010111111111",
      "status": "active",
      "archived_at": null,
      "project_count": 1
    },
    "projects": [
      {
        "id": "01JPROJECT",
        "name": "Villa",
        "status": "active",
        "received_piastres": 1000,
        "spent_piastres": 200,
        "balance_piastres": 800
      }
    ],
    "permissions": {"client_money": true, "clients_manage": true},
    "money": {
      "received_piastres": 1000,
      "spent_piastres": 200,
      "balance_piastres": 800
    },
    "can_edit": true,
    "can_archive": true,
    "can_unarchive": false,
    "can_delete": false
  }
}
''',
            200,
            headers: {'content-type': ['application/json']},
          );
        }),
    );

    final record = await api.getClient('01JCLIENT');
    api.close();

    expect(captured!.path, endsWith('/v1/clients/01JCLIENT/identity'));
    expect(record.client.name, 'Ahmed');
    expect(record.projects, hasLength(1));
    expect(record.projects.first.projectId, '01JPROJECT');
    expect(record.clientMoney?.balance, 800);
  });
}