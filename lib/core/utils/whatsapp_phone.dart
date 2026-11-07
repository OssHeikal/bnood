/// Normalize stored client phone to `wa.me` digits (E.164 without +).
abstract final class WhatsAppPhone {
  static String? waMeDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;

    if (digits.startsWith('20') && digits.length >= 12) {
      return digits;
    }
    if (digits.startsWith('0') && digits.length == 11) {
      return '20${digits.substring(1)}';
    }
    if (digits.length == 10 && digits.startsWith('1')) {
      return '20$digits';
    }
    if (digits.length >= 10 && digits.length <= 15) {
      return digits;
    }
    return null;
  }
}
