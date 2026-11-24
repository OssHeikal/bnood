import 'package:bnood/core/network/api/app_dio.dart';
import 'package:bnood/features/notifications/data/notifications_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

NotificationsApi _api(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = createAppDio(FakeSessionStore(token: 'tok'));
  dio.httpClientAdapter = ScriptedDioAdapter(handler);
  return NotificationsApi(dio: dio);
}

void main() {
  test('list parses paginated inbox rows', () async {
    final api = _api(
      (_) async => jsonResponse('''
{
  "success": true,
  "data": [
    {
      "id": "01note",
      "type": "low_balance",
      "title": "Low balance",
      "body": "Client low",
      "data": {"client_id": "01client"},
      "office_id": null,
      "read_at": null,
      "created_at": "2026-11-24T10:00:00+00:00"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total": 1,
    "last_page": 1
  }
}
'''),
    );
    final page = await api.list(page: 1, perPage: 20);
    expect(page.items.single.type, 'low_balance');
    expect(page.items.single.data['client_id'], '01client');
    expect(page.hasMore, isFalse);
  });

  test('unreadCount parses count', () async {
    final api = _api(
      (_) async => jsonResponse('''
{
  "success": true,
  "data": {"unread_count": 3}
}
'''),
    );
    expect(await api.unreadCount(), 3);
  });
}