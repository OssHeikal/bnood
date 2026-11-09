import '../formatting/display_digits.dart';
import 'money_format.dart';
import 'remote_money_units.dart';

/// EGP formatting for the online API (3 decimal major units, minor = major × 1000).
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
    final fracMillis = (frac * RemoteMoneyUnits.minorPerMajor).round().clamp(0, 999);
    final fracText = fracMillis.toString().padLeft(3, '0').replaceFirst(RegExp(r'0+$'), '');
    final body = fracText.isEmpty ? wholeText : '$wholeText.$fracText';
    return '$sign$body ${MoneyFormat.currencyLabel}';
  }

  static String withoutCurrencySuffix(String formatted) =>
      MoneyFormat.withoutCurrencySuffix(formatted);

  /// Parses a major amount with up to 3 fractional digits into minor units.
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
    var fracMillis = 0;
    if (parts.length > 1 && parts[1].isNotEmpty) {
      final frac = parts[1].padRight(3, '0').substring(0, 3);
      fracMillis = int.tryParse(frac) ?? 0;
    }
    final minor = whole * RemoteMoneyUnits.minorPerMajor + fracMillis;
    return negative ? -minor : minor;
  }

  /// Major-unit text for voucher amount fields (no currency suffix).
  static String majorInputTextFromMinor(int minor) {
    final major = RemoteMoneyUnits.minorToMajor(minor);
  final whole = major.truncateToDouble();
  if ((major - whole).abs() < 1e-9) return whole.toInt().toString();
    return major.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}
