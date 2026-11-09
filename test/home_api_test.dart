import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/home_api.dart';
import 'package:bnood/core/home/app_home_dashboard.dart';
import 'package:bnood/core/home/app_home_totals.dart';
import 'package:bnood/core/money/remote_money_format.dart';
import 'package:bnood/core/money/remote_money_units.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

HomeApi _homeApi(Future<ResponseBody> Function(RequestOptions options) handler) {
  final dio = createAppDio(FakeSessionStore(token: 'tok'));
  dio.httpClientAdapter = ScriptedDioAdapter(handler);
  return HomeApi(dio: dio);
}

void main() {
  group('AppHomeTotals', () {
    test('parses engineer totals from data json', () {
      final totals = AppHomeTotals.fromDataJson({
        'received': 2_500_000,
        'spent': 1_500_000,
        'remaining': 1_000_000,
      });
      expect(totals.receivedMinor, 2_500_000);
      expect(totals.spentMinor, 1_500_000);
      expect(totals.remainingMinor, 1_000_000);
      expect(RemoteMoneyFormat.formatMinor(totals.remainingMinor), '10,000 EGP');
      expect(RemoteMoneyUnits.minorToMajor(1_000_000), 10_000);
    });
  });

  group('AppHomeDashboard', () {
    test('parses client and craftsman previews', () {
      final dashboard = AppHomeDashboard.fromDataJson({
        'received': 100_000,
        'spent': 50_000,
        'remaining': 50_000,
        'clients': [
          {
            'id': 'c1',
            'name': 'Ahmed',
            'received': 100_000,
            'spent': 40_000,
            'remaining': 60_000,
          },
        ],
        'craftsmen': [
          {
            'id': 'p1',
            'name': 'Ali Craftsman',
            'last_activity_at': '2025-04-01T00:00:00+00:00',
            'paid': 1_200_000,
            'remaining': null,
            'clients_count': 4,
          },
        ],
      });
      expect(dashboard.totals.remainingMinor, 50_000);
      expect(dashboard.clients, hasLength(1));
      expect(dashboard.clients.first.remainingMinor, 60_000);
      expect(dashboard.craftsmen.single.name, 'Ali Craftsman');
      expect(dashboard.craftsmen.single.lastActivityAt, isNotNull);
      expect(dashboard.craftsmen.single.paidMinor, 1_200_000);
      expect(dashboard.craftsmen.single.remainingMinor, isNull);
      expect(dashboard.craftsmen.single.clientsCount, 4);
    });
  });

  group('HomeApi', () {
    test('GET /v1/home returns parsed dashboard', () async {
      late String path;
      final api = _homeApi((options) async {
        path = options.path;
        return jsonResponse(
          '{"success":true,"data":{"received":1000,"spent":500,"remaining":500,"clients":[],"craftsmen":[]}}',
        );
      });
      final dashboard = await api.getHomeDashboard();
      expect(path, '/v1/home');
      expect(dashboard.totals.receivedMinor, 1000);
      expect(dashboard.totals.remainingMinor, 500);
      expect(dashboard.clients, isEmpty);
      api.close();
    });
  });
}
