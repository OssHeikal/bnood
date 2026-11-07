import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/theme/app_size.dart';

/// Writes PDF bytes to a temp file before share — `XFile.fromData` is unreliable on some iOS builds.
typedef StatementShareFromFile = Future<void> Function(
  String filePath,
  String displayName, {
  Rect? sharePositionOrigin,
});

abstract final class StatementPdfExport {
  static StatementShareFromFile shareFromFile = _defaultShareFromFile;

  static Rect? lastSharePositionOrigin;

  @visibleForTesting
  static void resetShareForTests() {
    shareFromFile = _defaultShareFromFile;
    lastSharePositionOrigin = null;
  }

  static Future<void> _defaultShareFromFile(
    String filePath,
    String displayName, {
    Rect? sharePositionOrigin,
  }) async {
    final origin = sharePositionOrigin ?? lastSharePositionOrigin ?? _screenFallbackOrigin();
    lastSharePositionOrigin = origin;
    await Share.shareXFiles(
      [XFile(filePath, mimeType: 'application/pdf', name: displayName)],
      sharePositionOrigin: origin,
    );
  }

  /// Global rect for iOS/iPadOS `sharePositionOrigin` (popover anchor).
  static Rect sharePositionOriginFor(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final rect = box.localToGlobal(Offset.zero) & box.size;
      if (rect.width > 1 && rect.height > 1) {
        return rect;
      }
    }
    final media = MediaQuery.of(context);
    return _footerBandOrigin(media);
  }

  static Rect _footerBandOrigin(MediaQueryData media) {
    final size = media.size;
    final bottom = media.padding.bottom;
    final footerTop = size.height - bottom - AppSize.buttonHeight - AppSize.spaceMD - AppSize.spaceSM;
    final width = (size.width - AppSize.screenPadding * 2).clamp(120.0, size.width);
    return Rect.fromLTWH(AppSize.screenPadding, footerTop, width, AppSize.buttonHeight);
  }

  static Rect _screenFallbackOrigin() {
    // Conservative center-band anchor when no [BuildContext] is available (tests).
    return const Rect.fromLTWH(160, 700, 120, 48);
  }

  /// Returns a temp path with [bytes] flushed to disk.
  static Future<String> persistTempPdf(Uint8List bytes, String fileName) async {
    String dirPath;
    try {
      dirPath = (await getTemporaryDirectory()).path;
    } catch (e, st) {
      debugPrint('StatementPdfExport: path_provider temp dir unavailable: $e');
      debugPrint('$st');
      dirPath = Directory.systemTemp.path;
    }
    final path = p.join(dirPath, fileName);
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return path;
  }
}
