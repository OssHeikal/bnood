import 'dart:io';

import 'package:bnood/core/api/vouchers_api.dart';
import 'package:bnood/core/vouchers/vouchers_repository.dart';
import 'package:bnood/features/vouchers/voucher_remote_receipts.dart';
import 'package:bnood/features/vouchers/voucher_sheet_receipt.dart';
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

  test('dismiss without save sends no DELETE when nothing staged', () async {
    var deleteCount = 0;
    final api = _vouchersApi((options) async {
      if (options.method == 'DELETE' && options.uri.path.contains('/receipts/')) {
        deleteCount++;
      }
      return jsonResponse('{"success":true,"data":{}}');
    });
    final repo = VouchersRepository(api);
    final result = await syncVoucherReceiptsOnSave(
      repo: repo,
      voucherId: '01JV',
      receiptIdsToDelete: const [],
      receipts: const [],
    );
    expect(deleteCount, 0);
    expect(result.failedDeleteCount, 0);
    api.close();
  });

  test('save deletes staged receipt then uploads new image', () async {
    final calls = <String>[];
    final temp = writeReceiptTestJpeg(
      path: '${Directory.systemTemp.path}/bnood_receipt_orchestration.jpg',
    );
    final api = _vouchersApi((options) async {
      if (options.method == 'DELETE' && options.uri.path.endsWith('/receipts/r-old')) {
        calls.add('delete');
        return jsonResponse('{"success":true,"data":null}');
      }
      if (options.uri.path.contains('/vouchers/01JV/receipts') && options.method == 'POST') {
        calls.add('upload');
        return jsonResponse(
          '{"success":true,"data":{"id":"r-new","mime":"image/jpeg","size":10,"created_at":"2026-11-09T10:00:00Z"}}',
        );
      }
      return jsonResponse('{"success":true,"data":{}}');
    });
    final repo = VouchersRepository(api);
    final result = await syncVoucherReceiptsOnSave(
      repo: repo,
      voucherId: '01JV',
      receiptIdsToDelete: const ['r-old'],
      receipts: [
        VoucherSheetReceipt(localPath: temp.path, needsUpload: true),
      ],
    );
    expect(calls, ['delete', 'upload']);
    expect(result.failedDeleteCount, 0);
    expect(result.failedUploadCount, 0);
    expect(result.receipts.single.serverId, 'r-new');
    api.close();
  });

  test('failed delete on save skips upload and reports failure', () async {
    var uploadCount = 0;
    final temp = writeReceiptTestJpeg(
      path: '${Directory.systemTemp.path}/bnood_receipt_orchestration_fail.jpg',
    );
    final api = _vouchersApi((options) async {
      if (options.method == 'DELETE') {
        return jsonResponse(
          '{"success":false,"message":"nope","code":"server"}',
          statusCode: 500,
        );
      }
      if (options.method == 'POST' && options.uri.path.contains('/receipts')) {
        uploadCount++;
      }
      return jsonResponse('{"success":true,"data":{}}');
    });
    final repo = VouchersRepository(api);
    final pending = VoucherSheetReceipt(localPath: temp.path, needsUpload: true);
    final result = await syncVoucherReceiptsOnSave(
      repo: repo,
      voucherId: '01JV',
      receiptIdsToDelete: const ['r-old'],
      receipts: [pending],
    );
    expect(result.failedDeleteCount, 1);
    expect(result.failedDeleteIds, ['r-old']);
    expect(uploadCount, 0);
    expect(result.receipts.single.isPendingUpload, isTrue);
    api.close();
  });

  test('create path upload unchanged without staged deletes', () async {
    var deleteCount = 0;
    var uploadCount = 0;
    final temp = writeReceiptTestJpeg(
      path: '${Directory.systemTemp.path}/bnood_receipt_create_only.jpg',
    );
    final api = _vouchersApi((options) async {
      if (options.method == 'DELETE') deleteCount++;
      if (options.method == 'POST' && options.uri.path.contains('/receipts')) {
        uploadCount++;
        return jsonResponse(
          '{"success":true,"data":{"id":"r1","mime":"image/jpeg","size":1,"created_at":"2026-11-09T10:00:00Z"}}',
        );
      }
      return jsonResponse('{"success":true,"data":{}}');
    });
    final repo = VouchersRepository(api);
    final result = await syncVoucherReceiptsOnSave(
      repo: repo,
      voucherId: '01JV',
      receiptIdsToDelete: const [],
      receipts: [
        VoucherSheetReceipt(localPath: temp.path, needsUpload: true),
      ],
    );
    expect(deleteCount, 0);
    expect(uploadCount, 1);
    expect(result.failedUploadCount, 0);
    api.close();
  });
}
