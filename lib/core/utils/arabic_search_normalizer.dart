/// Arabic-insensitive search: alif/hamza variants, ta marbuta, ya/alef maqsura, etc.
abstract final class ArabicSearchNormalizer {
  static final _tashkeel = RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]');
  static final _tatweel = RegExp(r'\u0640');
  static final _spaces = RegExp(r'\s+');

  /// Normalizes text for comparison. Latin is lowercased; digits are unchanged.
  static String normalize(String input) {
    var s = input;
    s = s.replaceAll(_tashkeel, '');
    s = s.replaceAll(_tatweel, '');
    final buffer = StringBuffer();
    for (final rune in s.runes) {
      buffer.write(_mapChar(String.fromCharCode(rune)));
    }
    s = buffer.toString();
    s = s.replaceAll(_spaces, ' ').trim().toLowerCase();
    return s;
  }

  static String _mapChar(String ch) => switch (ch) {
        'أ' || 'إ' || 'آ' || 'ٱ' => 'ا',
        'ة' => 'ه',
        'ى' => 'ي',
        'ؤ' => 'و',
        'ئ' => 'ي',
        _ => ch,
      };

  static bool matches({required String query, required String haystack}) {
    final q = normalize(query);
    if (q.isEmpty) return true;
    return normalize(haystack).contains(q);
  }

  static bool matchesAny({required String query, required Iterable<String> haystacks}) {
    for (final h in haystacks) {
      if (matches(query: query, haystack: h)) return true;
    }
    return false;
  }
}
