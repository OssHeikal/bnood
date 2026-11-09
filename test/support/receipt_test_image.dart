import 'dart:io';

import 'package:image/image.dart' as img;

File writeReceiptTestJpeg({
  required String path,
  int width = 64,
  int height = 64,
  int quality = 85,
  int? seed,
}) {
  final image = img.Image(width: width, height: height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final shift = seed ?? 0;
      image.setPixelRgb(
        x,
        y,
        (x + shift) % 256,
        (y + shift) % 256,
        (x + y + shift) % 256,
      );
    }
  }
  final bytes = img.encodeJpg(image, quality: quality);
  return File(path)..writeAsBytesSync(bytes);
}
