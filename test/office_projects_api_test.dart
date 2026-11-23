import 'package:bnood/core/network/api/app_dio.dart';
import 'package:bnood/features/clients/data/client_list_archive_filter.dart';
import 'package:bnood/features/projects/data/office_projects_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

OfficeProjectsApi _api(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = createAppDio(FakeSessionStore(token: 'tok'));
  dio.httpClientAdapter = ScriptedDioAdapter(handler);
  return OfficeProjectsApi(dio: dio);
}

void main() {
  test('listProjects calls /v1/office/projects with status filter', () async {
  Uri? captured;
  final api = _api((options) async {
    captured = options.uri;
    return ResponseBody.fromString(
      '''
{
  "success": true,
  "data": [
    {
      "id": "01JPROJ",
      "name": "Villa",
      "client_id": "01JCLIENT",
      "client_name": "Ahmed",
      "status": "active",
      "balance_piastres": 1000,
      "received_piastres": 5000,
      "spent_piastres": 4000
    }
  ],
  "meta": {"current_page": 1, "per_page": 50, "total": 1}
}
''',
      200,
      headers: {'content-type': ['application/json']},
    );
  });

  final page = await api.listProjects(
    status: ClientListArchiveFilter.active,
    page: 1,
    perPage: 50,
  );
  api.close();

  expect(captured!.path, endsWith('/v1/office/projects'));
  expect(captured!.queryParameters['status'], 'active');
  expect(page.items, hasLength(1));
  expect(page.items.first.projectName, 'Villa');
  expect(page.items.first.clientName, 'Ahmed');
  expect(page.items.first.balancePiastres, 1000);
});
}