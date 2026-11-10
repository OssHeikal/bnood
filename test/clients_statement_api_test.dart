import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/clients_api.dart';
import 'package:bnood/core/clients/client_statement_record.dart';
import 'package:bnood/core/money/remote_money_format.dart';
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
  group('AppClientStatement', () {
    test('parses period totals and item spend rows', () {
      final statement = AppClientStatement.fromDataJson({
        'from': '2026-01-01',
        'to': '2026-11-09',
        'received': 1_000_000,
        'spent': 800_000,
        'remaining': 200_000,
        'items': [
          {'id': 'i1', 'name': 'Tiles', 'spent': 500_000},
          {'id': 'i2', 'name': 'Paint', 'spent': 300_000},
        ],
      });
      expect(statement.from, '2026-01-01');
      expect(statement.openingBalanceMinor, 0);
      expect(statement.closingBalanceMinor, 200_000);
      expect(statement.remainingMinor, 200_000);
      expect(statement.items.length, 2);
      expect(statement.items.first.iconKey, isNull);
      expect(statement.items.first.colorKey, isNull);
      expect(statement.items.first.spentMinor, 500_000);
      expect(RemoteMoneyFormat.formatMinor(statement.items.first.spentMinor), '5,000 EGP');
    });

    test('opening and closing balance fields optional with fallbacks', () {
      final statement = AppClientStatement.fromDataJson({
        'from': '2026-01-01',
        'to': '2026-01-31',
        'opening_balance': 100_000,
        'received': 50_000,
        'spent': 30_000,
        'closing_balance': 120_000,
        'remaining': 120_000,
        'items': [],
      });
      expect(statement.openingBalanceMinor, 100_000);
      expect(statement.closingBalanceMinor, 120_000);
      expect(statement.remainingMinor, 120_000);
    });
  });

  group('AppClientItemSpend', () {
    test('parses materials labor icon and color fields', () {
      final item = AppClientStatementItemSpend.fromDataJson({
        'id': '01JVITEM',
        'name': 'Plumbing',
        'spent': 1_300_000,
        'materials': 1_000_000,
        'labor': 300_000,
        'icon_key': 'plumbing',
        'color_key': 'blue',
      });
      expect(item.materialsMinor, 1_000_000);
      expect(item.laborMinor, 300_000);
      expect(item.spentMinor, 1_300_000);
      expect(item.iconKey, 'plumbing');
      expect(item.colorKey, 'blue');
    });

    test('parses all-time item list', () {
      final spend = AppClientItemSpend.fromDataJson({
        'items': [
          {
            'id': 'i1',
            'name': 'Labor',
            'spent': 150,
            'materials': 0,
            'labor': 150,
            'icon_key': 'category',
            'color_key': 'teal',
          },
        ],
      });
      expect(spend.items.single.name, 'Labor');
      expect(spend.items.single.spentMinor, 150);
      expect(spend.items.single.laborMinor, 150);
      expect(RemoteMoneyFormat.formatMinor(150), '1.5 EGP');
    });
  });

  group('ClientsApi statements', () {
    test('getClientStatement sends from and to query params', () async {
      late Uri uri;
      final api = _clientsApi((options) async {
        uri = options.uri;
        return jsonResponse(
          '{"success":true,"data":{"from":"2026-01-01","to":"2026-01-31","received":0,"spent":0,"remaining":0,"items":[]}}',
        );
      });
      await api.getClientStatement(clientId: 'c1', from: '2026-01-01', to: '2026-01-31');
      expect(uri.queryParameters['from'], '2026-01-01');
      expect(uri.queryParameters['to'], '2026-01-31');
      expect(uri.path, endsWith('/clients/c1/statement'));
      api.close();
    });

    test('getClientItemSpend hits item-spend path', () async {
      late String path;
      final api = _clientsApi((options) async {
        path = options.path;
        return jsonResponse('{"success":true,"data":{"items":[]}}');
      });
      final spend = await api.getClientItemSpend('c9');
      expect(path, endsWith('/clients/c9/item-spend'));
      expect(spend.items, isEmpty);
      api.close();
    });
  });
}
