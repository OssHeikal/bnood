import '../formatting/display_digits.dart';

/// V1 **implementation choice** (not a locked product decision — see docs/technical-choices.md).
class BasisPoints {
  const BasisPoints(this.value);

  /// 1% = 100 basis points; max 100% = 10000.
  final int value;

  static const int max = 10000;

  static BasisPoints? parsePercentInput(String input) {
    final t = DisplayDigits.toWesternDigits(input.trim().replaceAll('%', ''));
    if (t.isEmpty) return null;
    final parts = t.split('.');
    final whole = int.tryParse(parts.first);
    if (whole == null || whole < 0 || whole > 100) return null;
    var frac = 0;
    if (parts.length > 1) {
      final f = parts[1].padRight(2, '0').substring(0, 2);
      final fp = int.tryParse(f);
      if (fp == null) return null;
      frac = fp;
    }
    final bp = whole * 100 + (frac ~/ 1);
    if (bp > max) return null;
    return BasisPoints(bp);
  }

  static String formatPercent(int? basisPoints) {
    if (basisPoints == null) return '—';
    final whole = basisPoints ~/ 100;
    final frac = basisPoints % 100;
    if (frac == 0) return '$whole%';
    return '$whole.${frac.toString().padLeft(2, '0')}%';
  }
}
