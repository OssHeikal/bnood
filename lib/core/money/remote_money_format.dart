import '../formatting/display_digits.dart';
import 'money_format.dart';
import 'remote_money_units.dart';

/// EGP formatting for the online API (2 decimal major units, minor = major × 100).
class RemoteMoneyFormat {
  RemoteMoneyFormat._();

  static String formatMinor(int minor, {String locale = 'ar_EG'}) =>
      formatMajor(RemoteMoneyUnits.minorToMajor(minor), locale: locale);

  static String formatMajor(double major, {String locale = 'ar_EG'}) {
    final sign = major < 0 ? '−' : '';
    final magnitude = major.abs();
    final whole = magnitude.truncateToDouble();
    final frac = magnitude - whole;
    final wholeText = DisplayDigits.formatInteger(whole.toInt());
    if (frac.abs() < 1e-9) {
      return '$sign$wholeText ${MoneyFormat.currencyLabel}';
    }
    final fracMinor = (frac * RemoteMoneyUnits.minorPerMajor).round().clamp(0, 99);
    final fracText = fracMinor.toString().padLeft(2, '0').replaceFirst(RegExp(r'0+$'), '');
    final body = fracText.isEmpty ? wholeText : '$wholeText.$fracText';
    return '$sign$body ${MoneyFormat.currencyLabel}';
  }

  static String withoutCurrencySuffix(String formatted) =>
      MoneyFormat.withoutCurrencySuffix(formatted);

  /// Parses a major amount with up to 2 fractional digits into minor units.
  static int? parseMajorInput(String input) {
    final normalized = DisplayDigits.toWesternDigits(
      input.trim().replaceAll(',', '').replaceAll(' ', ''),
    );
    if (normalized.isEmpty) return null;
    final negative = normalized.startsWith('-') || normalized.startsWith('−');
    final body = normalized.replaceFirst(RegExp(r'^[-−]'), '');
    final parts = body.split('.');
    final whole = int.tryParse(parts.first);
    if (whole == null) return null;
    var fracMinor = 0;
    if (parts.length > 1 && parts[1].isNotEmpty) {
      final frac = parts[1].padRight(2, '0').substring(0, 2);
      fracMinor = int.tryParse(frac) ?? 0;
    }
    final minor = whole * RemoteMoneyUnits.minorPerMajor + fracMinor;
    return negative ? -minor : minor;
  }

  /// Major-unit text for voucher amount fields (no currency suffix).
  static String majorInputTextFromMinor(int minor) {
    final major = RemoteMoneyUnits.minorToMajor(minor);
    final whole = major.truncateToDouble();
    if ((major - whole).abs() < 1e-9) return whole.toInt().toString();
    return major.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}
