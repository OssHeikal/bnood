import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

/// Online receipt upload cap (API validation).
const receiptApiMaxBytes = 5 * 1024 * 1024;

/// Stay slightly under [receiptApiMaxBytes] on the wire.
const receiptUploadTargetBytes = 4900000;

/// Long-edge resize cap for receipt readability.
const receiptMaxLongEdge = 1920;

class ReceiptImageCompressionException implements Exception {
  const ReceiptImageCompressionException();
}

enum _ReceiptOutputFormat { jpeg, png, webp }

class ReceiptPreparedUpload {
  const ReceiptPreparedUpload({
    required this.path,
    required this.deleteAfterUpload,
  });

  final String path;
  final bool deleteAfterUpload;

  Future<void> dispose() async {
    if (!deleteAfterUpload) return;
    try {
      await File(path).delete();
    } catch (_) {}
  }
}

_ReceiptOutputFormat _formatForSourcePath(String sourcePath) {
  switch (p.extension(sourcePath).toLowerCase()) {
    case '.png':
      return _ReceiptOutputFormat.png;
    case '.webp':
      return _ReceiptOutputFormat.webp;
    default:
      return _ReceiptOutputFormat.jpeg;
  }
}

String _extensionForFormat(_ReceiptOutputFormat format) {
  return switch (format) {
    _ReceiptOutputFormat.jpeg => '.jpg',
    _ReceiptOutputFormat.png => '.png',
    _ReceiptOutputFormat.webp => '.webp',
  };
}

List<int> _encode(img.Image image, _ReceiptOutputFormat format, int quality) {
  return switch (format) {
    _ReceiptOutputFormat.jpeg => img.encodeJpg(image, quality: quality),
    _ReceiptOutputFormat.png => img.encodePng(image, level: 6),
    _ReceiptOutputFormat.webp => img.encodeJpg(image, quality: quality),
  };
}

img.Image _resizeLongEdge(img.Image image, int maxLongEdge) {
  final w = image.width;
  final h = image.height;
  final long = math.max(w, h);
  if (long <= maxLongEdge) return image;
  if (w >= h) {
    return img.copyResize(image, width: maxLongEdge, interpolation: img.Interpolation.linear);
  }
  return img.copyResize(image, height: maxLongEdge, interpolation: img.Interpolation.linear);
}

/// Compresses/resizes a picked receipt for `POST /vouchers/{id}/receipts` when needed.
Future<ReceiptPreparedUpload> prepareReceiptImageForUpload(String sourcePath) async {
  final source = File(sourcePath);
  if (!await source.exists()) {
    throw const ReceiptImageCompressionException();
  }
  final raw = await source.readAsBytes();
  final decoded = img.decodeImage(raw);
  if (decoded == null) {
    throw const ReceiptImageCompressionException();
  }
  final oriented = img.bakeOrientation(decoded);
  final longEdge = math.max(oriented.width, oriented.height);
  if (raw.length <= receiptUploadTargetBytes && longEdge <= receiptMaxLongEdge) {
    return ReceiptPreparedUpload(path: sourcePath, deleteAfterUpload: false);
  }

  var format = _formatForSourcePath(sourcePath);
  var quality = 88;
  var edge = receiptMaxLongEdge;
  List<int>? encoded;

  for (var attempt = 0; attempt < 16; attempt++) {
    final working = _resizeLongEdge(oriented, edge);
    encoded = _encode(working, format, quality);
    if (encoded.length <= receiptApiMaxBytes) {
      break;
    }

    if (format == _ReceiptOutputFormat.png || format == _ReceiptOutputFormat.webp) {
      format = _ReceiptOutputFormat.jpeg;
      quality = 88;
      continue;
    }

    if (quality > 48) {
      quality -= 8;
      continue;
    }

    if (edge > 1200) {
      edge = (edge * 0.82).round();
      quality = 84;
      continue;
    }

    throw const ReceiptImageCompressionException();
  }

  if (encoded == null || encoded.length > receiptApiMaxBytes) {
    throw const ReceiptImageCompressionException();
  }

  final outPath = p.join(
    p.dirname(sourcePath),
    'receipt_upload_${DateTime.now().microsecondsSinceEpoch}${_extensionForFormat(format)}',
  );
  await File(outPath).writeAsBytes(encoded, flush: true);
  return ReceiptPreparedUpload(path: outPath, deleteAfterUpload: true);
}
