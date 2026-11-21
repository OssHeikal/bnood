import 'package:intl/intl.dart';

/// App-generated numbers always use Western digits (0–9), including under Arabic UI locale.
abstract final class DisplayDigits {
  static const _eastern = '٠١٢٣٤٥٦٧٨٩';
  static const _western = '0123456789';

  static NumberFormat decimalPattern() => NumberFormat.decimalPattern('en_US');

  /// Maps Eastern Arabic numerals to ASCII; other code units unchanged.
  static String toWesternDigits(String input) {
    if (input.isEmpty) return input;
    final buffer = StringBuffer();
    for (final unit in input.runes) {
      final char = String.fromCharCode(unit);
      final idx = _eastern.indexOf(char);
      buffer.write(idx >= 0 ? _western[idx] : char);
    }
    return buffer.toString();
  }

  static String formatInteger(int value) => decimalPattern().format(value);
}
