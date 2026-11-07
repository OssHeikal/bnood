import '../formatting/display_digits.dart';

/// EGP stored as integer piastres (1 EGP = 100 piastres).
class MoneyFormat {
  MoneyFormat._();

  /// App-generated money always suffixes uppercase `EGP` (Arabic and English UI).
  static const String currencyLabel = 'EGP';

  static String formatPiastres(int piastres, {String locale = 'ar_EG'}) {
    final magnitude = piastres.abs();
    final pounds = magnitude ~/ 100;
    final cents = magnitude % 100;
    final whole = DisplayDigits.formatInteger(pounds);
    if (cents == 0) {
      return '$whole $currencyLabel';
    }
    final frac = cents.toString().padLeft(2, '0');
    return '$whole.$frac $currencyLabel';
  }

  static String withoutCurrencySuffix(String formatted) =>
      formatted.replaceAll(RegExp(r'\s*EGP\s*$', caseSensitive: false), '').replaceAll(RegExp(r'\s*ج\.م\s*$'), '');

  static int? parseEgpInput(String input) {
    final normalized = DisplayDigits.toWesternDigits(input.trim().replaceAll(',', '').replaceAll(' ', ''));
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
