import 'dart:io';
import 'dart:math' as math;

import 'package:bnood/core/api/vouchers_api.dart';
import 'package:bnood/core/vouchers/vouchers_repository.dart';
import 'package:bnood/features/vouchers/receipt_image_compress.dart';
import 'package:bnood/features/vouchers/voucher_remote_receipts.dart';
import 'package:bnood/features/vouchers/voucher_sheet_receipt.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:bnood/core/api/app_dio.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

VouchersApi _vouchersApi(Future<ResponseBody> Function(RequestOptions options) handler) {
  final dio = createAppDio(FakeSessionStore(token: 'tok'));
  dio.httpClientAdapter = ScriptedDioAdapter(handler);
  return VouchersApi(dio: dio);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('upload posts compressed bytes under 5MB for oversized source', () async {
    final image = img.Image(width: 3600, height: 2700);
    final random = math.Random(3);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        image.setPixelRgb(
          x,
          y,
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
        );
      }
    }
    final noisy = img.encodeJpg(image, quality: 96);
    expect(noisy.length, greaterThan(receiptApiMaxBytes));

    final dir = Directory.systemTemp.createTempSync('bnood_receipt_upload_');
    final source = File('${dir.path}/camera.jpg')..writeAsBytesSync(noisy);

    int? postedLength;
    final api = _vouchersApi((options) async {
      if (options.method == 'POST' && options.uri.path.contains('/receipts')) {
        final form = options.data as FormData;
        final part = form.files.first.value;
        postedLength = await part.length;
        return jsonResponse(
          '{"success":true,"data":{"id":"r1","mime":"image/jpeg","size":$postedLength,"created_at":"2026-11-09T10:00:00Z"}}',
        );
      }
      return jsonResponse('{"success":true,"data":{}}');
    });
    final repo = VouchersRepository(api);

    final upload = await uploadPendingReceiptsBestEffort(
      repo: repo,
      voucherId: '01JV',
      receipts: [
        VoucherSheetReceipt(localPath: source.path, needsUpload: true),
      ],
    );

    expect(upload.failedCount, 0);
    expect(postedLength, isNotNull);
    expect(postedLength!, lessThanOrEqualTo(receiptApiMaxBytes));
    expect(upload.receipts.single.serverId, 'r1');
    api.close();
    dir.deleteSync(recursive: true);
  });
}
