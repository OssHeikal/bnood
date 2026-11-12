import 'package:bnood/core/api/vouchers_api.dart';
import 'package:bnood/core/vouchers/app_voucher_receipt.dart';
import 'package:bnood/core/vouchers/vouchers_repository.dart';
import 'package:bnood/features/vouchers/voucher_remote_receipts.dart';
import 'package:bnood/features/vouchers/voucher_sheet_receipt.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bnood/core/api/app_dio.dart';

import 'support/fake_session_store.dart';
import 'support/receipt_test_image.dart';
import 'support/scripted_dio_adapter.dart';

VouchersApi _vouchersApi(Future<ResponseBody> Function(RequestOptions options) handler) {
  final dio = createAppDio(FakeSessionStore(token: 'tok'));
  dio.httpClientAdapter = ScriptedDioAdapter(handler);
  return VouchersApi(dio: dio);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('create sends date and payment_method', () async {
    late Object? body;
    final api = _vouchersApi((options) async {
      body = options.data;
      return jsonResponse(
        '{"success":true,"data":{"id":"01JV","client_id":"c1","type":"receive","amount":5000,"date":"2026-11-09","payment_method":"cash"}}',
      );
    });
    final voucher = await api.createVoucher(
      clientId: 'c1',
      type: 'receive',
      amountMinor: 5000,
      voucherDate: '2026-11-09',
      method: 'cash',
    );
    expect((body! as Map)['date'], '2026-11-09');
    expect((body! as Map)['payment_method'], 'cash');
    expect((body! as Map).containsKey('voucher_date'), isFalse);
    expect((body! as Map).containsKey('method'), isFalse);
    expect(voucher.method, 'cash');
    api.close();
  });

  test('parses nested receipts metadata', () {
    final receipt = AppVoucherReceipt.fromDataJson({
      'id': 'r1',
      'mime': 'image/jpeg',
      'size': 1200,
      'created_at': '2026-11-09T10:00:00Z',
    });
    expect(receipt.mime, 'image/jpeg');
    expect(receipt.size, 1200);
  });

  test('failed receipt upload keeps voucher id for retry without second create', () async {
    var createCount = 0;
    var uploadCount = 0;
    final temp = writeReceiptTestJpeg(
      path: '${Directory.systemTemp.path}/bnood_receipt_test.jpg',
    );
    final api = _vouchersApi((options) async {
      if (options.uri.path.contains('/receipts') && options.method == 'POST') {
        uploadCount++;
        return jsonResponse(
          '{"success":false,"message":"bad","code":"invalid_mime"}',
          statusCode: 422,
        );
      }
      if (options.method == 'POST') {
        createCount++;
      }
      return jsonResponse(
        '{"success":true,"data":{"id":"01JV","client_id":"c1","type":"receive","amount":100,"date":"2026-11-09","payment_method":"cash"}}',
      );
    });
    final repo = VouchersRepository(api);
    final voucher = await repo.createVoucher(
      clientId: 'c1',
      type: 'receive',
      amountMinor: 100,
      voucherDate: '2026-11-09',
      method: 'cash',
    );
    expect(voucher.id, '01JV');
    expect(createCount, 1);
    expect(uploadCount, 0);

    final upload = await uploadPendingReceiptsBestEffort(
      repo: repo,
      voucherId: voucher.id,
      receipts: [
        VoucherSheetReceipt(localPath: temp.path, needsUpload: true),
      ],
    );
    expect(upload.failedCount, 1);
    expect(upload.receipts.single.isPendingUpload, isTrue);
    expect(uploadCount, 1);
    expect(createCount, 1);
    api.close();
  });

}
