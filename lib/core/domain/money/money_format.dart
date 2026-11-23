import '../formatting/display_digits.dart';

/// EGP stored as integer piastres (1 EGP = 100 piastres).
class MoneyFormat {
  MoneyFormat._();

  /// App-generated money always suffixes uppercase `EGP` (Arabic and English UI).
  static const String currencyLabel = 'EGP';

  /// Display-only whole pounds from stored piastres (half away from zero).
  static int displayWholeEgpFromPiastres(int piastres) {
    if (piastres >= 0) {
      return (piastres + 50) ~/ 100;
    }
    return (piastres - 50) ~/ 100;
  }

  static String formatPiastres(int piastres, {String locale = 'ar_EG'}) {
    final pounds = displayWholeEgpFromPiastres(piastres);
    final sign = pounds < 0 ? '−' : '';
    final whole = DisplayDigits.formatInteger(pounds.abs());
    final body = sign.isEmpty ? whole : '$sign$whole';
    return '$body $currencyLabel';
  }

  static String withoutCurrencySuffix(String formatted) => formatted
      .replaceAll(RegExp(r'\s*EGP\s*$', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*ج\.م\s*$'), '');

  static int? parseEgpInput(String input) {
    final normalized = DisplayDigits.toWesternDigits(
      input.trim().replaceAll(',', '').replaceAll(' ', ''),
    );
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
