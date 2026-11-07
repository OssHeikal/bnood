import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// Bundled Cairo fonts (SIL OFL — see assets/fonts/OFL.txt).
class PdfFonts {
  PdfFonts._(this.regular, this.bold);

  final pw.Font regular;
  final pw.Font bold;

  static PdfFonts? _cache;

  static Future<PdfFonts> load() async {
    if (_cache != null) return _cache!;
    final regData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
    _cache = PdfFonts._(
      pw.Font.ttf(regData),
      pw.Font.ttf(boldData),
    );
    return _cache!;
  }

  @visibleForTesting
  static void clearCache() => _cache = null;
}
