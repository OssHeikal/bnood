import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/home_api.dart';
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
        'received': 25_000_000,
        'spent': 15_000_000,
        'remaining': 10_000_000,
      });
      expect(totals.receivedMinor, 25_000_000);
      expect(totals.spentMinor, 15_000_000);
      expect(totals.remainingMinor, 10_000_000);
      expect(RemoteMoneyFormat.formatMinor(totals.remainingMinor), '10,000 EGP');
      expect(RemoteMoneyUnits.minorToMajor(10_000_000), 10_000);
    });
  });

  group('HomeApi', () {
    test('GET /v1/home returns parsed totals', () async {
      late String path;
      final api = _homeApi((options) async {
        path = options.path;
        return jsonResponse(
          '{"success":true,"data":{"received":1000,"spent":500,"remaining":500}}',
        );
      });
      final totals = await api.getHomeTotals();
      expect(path, '/v1/home');
      expect(totals.receivedMinor, 1000);
      expect(totals.remainingMinor, 500);
      api.close();
    });
  });
}
