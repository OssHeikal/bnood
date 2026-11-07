/// Left-to-right isolate (U+2066 … U+2069).
///
/// One run keeps a value before its unit in Arabic, and keeps a unit such as
/// `10^9/L` from reversing.
abstract final class LtrIsolate {
  static const open = '\u2066';
  static const close = '\u2069';

  static String isolate(String value) => '$open$value$close';

  static String valueWithUnit(String value, String? unit) {
    final trimmed = unit?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return isolate(value);
    }
    return isolate('$value $trimmed');
  }
}
