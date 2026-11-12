/// Egyptian mobile numbers: 11 digits, prefix 010 / 011 / 012 / 015.
abstract final class EgyptMobilePhone {
  static const _allowedPrefixes = {'010', '011', '012', '015'};

  /// Returns canonical 11-digit local mobile, or null when invalid.
  static String? normalizeDigits(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    var digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0020')) {
      digits = digits.substring(4);
    } else if (digits.startsWith('20') && digits.length > 11) {
      digits = digits.substring(2);
    }

    if (digits.length == 10 && digits.startsWith('1')) {
      digits = '0$digits';
    }

    if (digits.length != 11 || !digits.startsWith('01')) return null;
    final prefix = digits.substring(0, 3);
    if (!_allowedPrefixes.contains(prefix)) return null;
    return digits;
  }

  static bool isValid(String raw) => normalizeDigits(raw) != null;
}
