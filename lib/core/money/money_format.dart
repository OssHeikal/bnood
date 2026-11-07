import 'package:intl/intl.dart';

/// EGP stored as integer piastres (1 EGP = 100 piastres).
class MoneyFormat {
  MoneyFormat._();

  static String formatPiastres(int piastres, {String locale = 'ar_EG'}) {
    final pounds = piastres ~/ 100;
    final cents = piastres % 100;
    final number = NumberFormat.decimalPattern(locale);
    final whole = number.format(pounds);
    if (cents == 0) {
      return '$whole ج.م';
    }
    return '$whole.${cents.toString().padLeft(2, '0')} ج.م';
  }

  static int? parseEgpInput(String input) {
    final normalized = input.trim().replaceAll(',', '');
    if (normalized.isEmpty) return null;
    final parts = normalized.split('.');
    final whole = int.tryParse(parts.first);
    if (whole == null) return null;
    var frac = 0;
    if (parts.length > 1) {
      final f = parts[1].padRight(2, '0').substring(0, 2);
      frac = int.tryParse(f) ?? 0;
    }
    return whole * 100 + frac;
  }

  /// Engineer profit uses basis points; rounded down (documented policy).
  static int estimatedProfitPiastres({
    required int totalSpendPiastres,
    required int engineerBasisPoints,
  }) {
    return (totalSpendPiastres * engineerBasisPoints) ~/ 10000;
  }
}
