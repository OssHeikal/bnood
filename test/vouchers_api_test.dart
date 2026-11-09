import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/core/api/vouchers_api.dart';
import 'package:bnood/core/vouchers/app_voucher_record.dart';
import 'package:bnood/core/money/remote_money_units.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bnood/core/api/app_dio.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

VouchersApi _vouchersApi(Future<ResponseBody> Function(RequestOptions options) handler) {
  final dio = createAppDio(FakeSessionStore(token: 'tok'));
  dio.httpClientAdapter = ScriptedDioAdapter(handler);
  return VouchersApi(dio: dio);
}

void main() {
  group('AppVoucher', () {
    test('maps spend labor provider and minor amount', () {
      final voucher = AppVoucher.fromDataJson({
        'id': '01JV',
        'client_id': 'c1',
        'type': 'spend',
        'amount': 1500,
        'date': '2026-11-09',
        'payment_method': 'cash',
        'item_id': 'i1',
        'provider_id': 'p1',
        'expense_classification': 'labor',
        'item': {'name': 'Labor'},
        'provider': {'name': 'Karim'},
      });
      expect(voucher.amountMinor, 1500);
      expect(voucher.craftsmanId, 'p1');
      expect(voucher.supplierId, isNull);
      expect(RemoteMoneyUnits.minorToMajor(voucher.amountMinor), 1.5);
    });
  });

  group('VouchersApi', () {
    test('create sends integer amount and receive omits spend fields', () async {
      late Object? body;
      final api = _vouchersApi((options) async {
        body = options.data;
        return jsonResponse(
          '{"success":true,"data":{"id":"01JV","client_id":"c1","type":"receive","amount":5000,"date":"2026-11-09","payment_method":"cash"}}',
        );
      });
      await api.createVoucher(
        clientId: 'c1',
        type: 'receive',
        amountMinor: 5000,
        voucherDate: '2026-11-09',
        method: 'cash',
      );
      expect((body! as Map)['amount'], 5000);
      expect((body! as Map)['date'], '2026-11-09');
      expect((body! as Map)['payment_method'], 'cash');
      expect((body! as Map).containsKey('item_id'), isFalse);
      api.close();
    });

    test('listClientVouchers sends item_id query param', () async {
      late Uri uri;
      final api = _vouchersApi((options) async {
        uri = options.uri;
        return jsonResponse(
          '{"success":true,"data":[],"meta":{"page":1,"per_page":20,"total":0}}',
        );
      });
      await api.listClientVouchers(clientId: 'c1', itemId: '01JVITEM', page: 1, perPage: 20);
      expect(uri.queryParameters['item_id'], '01JVITEM');
      expect(uri.path, endsWith('/clients/c1/vouchers'));
      api.close();
    });

    test('listClientVouchers sends q sort and date filters', () async {
      late Uri uri;
      final api = _vouchersApi((options) async {
        uri = options.uri;
        return jsonResponse(
          '{"success":true,"data":[],"meta":{"page":1,"per_page":20,"total":0}}',
        );
      });
      await api.listClientVouchers(
        clientId: 'c1',
        q: 'invoice',
        from: '2026-01-01',
        to: '2026-01-31',
        sort: 'date_asc',
        page: 2,
        perPage: 20,
      );
      expect(uri.queryParameters['q'], 'invoice');
      expect(uri.queryParameters['from'], '2026-01-01');
      expect(uri.queryParameters['to'], '2026-01-31');
      expect(uri.queryParameters['sort'], 'date_asc');
      expect(uri.queryParameters['page'], '2');
      api.close();
    });

    test('client_archived maps to exception', () async {
      final api = _vouchersApi(
        (_) async => jsonResponse(
          '{"success":false,"message":"archived","code":"client_archived"}',
          statusCode: 422,
        ),
      );
      expect(
        () => api.createVoucher(
          clientId: 'c1',
          type: 'receive',
          amountMinor: 1,
          voucherDate: '2026-11-09',
          method: 'cash',
        ),
        throwsA(isA<AuthApiException>().having((e) => e.isClientArchivedVoucher, 'archived', isTrue)),
      );
      api.close();
    });
  });
}
