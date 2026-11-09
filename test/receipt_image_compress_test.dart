import 'dart:io';
import 'dart:math' as math;

import 'package:bnood/features/vouchers/receipt_image_compress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('compresses oversized fixture under 5MB', () async {
    final image = img.Image(width: 4000, height: 3000);
    final random = math.Random(7);
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
    final noisy = img.encodeJpg(image, quality: 95);
    expect(noisy.length, greaterThan(receiptApiMaxBytes));

    final dir = Directory.systemTemp.createTempSync('bnood_receipt_compress_');
    final source = File('${dir.path}/large.jpg')..writeAsBytesSync(noisy);

    final prepared = await prepareReceiptImageForUpload(source.path);
    final compressedSize = await File(prepared.path).length();
    expect(compressedSize, lessThanOrEqualTo(receiptApiMaxBytes));
    expect(prepared.deleteAfterUpload, isTrue);
    await prepared.dispose();
    dir.deleteSync(recursive: true);
  });

  test('small image under caps is not recompressed', () async {
    final image = img.Image(width: 1200, height: 900);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        image.setPixelRgb(x, y, 240, 240, 240);
      }
    }
    final bytes = img.encodeJpg(image, quality: 85);
    expect(bytes.length, lessThan(receiptUploadTargetBytes));

    final dir = Directory.systemTemp.createTempSync('bnood_receipt_small_');
    final source = File('${dir.path}/small.jpg')..writeAsBytesSync(bytes);

    final prepared = await prepareReceiptImageForUpload(source.path);
    expect(prepared.path, source.path);
    expect(prepared.deleteAfterUpload, isFalse);
    dir.deleteSync(recursive: true);
  });
}
