/// Thin space so Arabic initials do not join as a single ligature (matches office dashboard).
const officeInitialsSeparator = '\u2009';

final _honorificPrefixes = <RegExp>[
  RegExp(r'^المهندس\s+الدكتور\s+', unicode: true),
  RegExp(r'^مهندس\s+دكتور\s+', unicode: true),
  RegExp(r'^م\.?\s*د\.?\s+', unicode: true),
  RegExp(r'^م\.?\s+', unicode: true),
  RegExp(r'^م/\s*', unicode: true),
  RegExp(r'^د/\s*', unicode: true),
  RegExp(r'^أ/\s*', unicode: true),
  RegExp(r'^ا/\s*', unicode: true),
  RegExp(r'^أستاذ\s+', unicode: true),
  RegExp(r'^مهندس\s+', unicode: true),
  RegExp(r'^دكتور\s+', unicode: true),
  RegExp(r'^Eng\.?\s*', caseSensitive: false, unicode: true),
  RegExp(r'^Dr\.?\s*', caseSensitive: false, unicode: true),
  RegExp(r'^Mr\.?\s*', caseSensitive: false, unicode: true),
  RegExp(r'^Mrs\.?\s*', caseSensitive: false, unicode: true),
  RegExp(r'^Ms\.?\s*', caseSensitive: false, unicode: true),
];

String stripOfficeHonorificPrefixes(String value) {
  var name = value.trim();
  var changed = true;
  while (changed) {
    changed = false;
    for (final pattern in _honorificPrefixes) {
      final next = name.replaceFirst(pattern, '');
      if (next != name) {
        name = next.trim();
        changed = true;
        break;
      }
    }
  }
  return name;
}

String stripLeadingAl(String word) {
  final w = word.trim();
  if (w.startsWith('ال') && w.length > 2) {
    return w.substring(2);
  }
  return w;
}

String normalizeInitialLetter(String char) {
  if (char.isEmpty) return '';
  return char.replaceAll(RegExp(r'[أإآ]'), 'ا');
}

bool isLatinOfficeName(String text) {
  final sample = text.trim();
  if (sample.isEmpty) return false;
  final hasArabic = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]')
      .hasMatch(sample);
  final hasLatin = RegExp(r'[A-Za-z]').hasMatch(sample);
  return hasLatin && !hasArabic;
}

/// Office-dashboard-style initials for list avatars and profile chips.
String personInitials(String? rawName) {
  final cleaned = stripOfficeHonorificPrefixes(rawName ?? '');
  final words = cleaned
      .split(RegExp(r'\s+'))
      .map(stripLeadingAl)
      .where((w) => w.isNotEmpty)
      .toList();

  if (words.isEmpty) return '—';

  final latin = isLatinOfficeName(cleaned);

  if (words.length == 1) {
    final letter = latin
        ? _latinInitial(words.first)
        : normalizeInitialLetter(_firstChar(words.first));
    return letter.isEmpty ? '—' : letter;
  }

  final first = _firstChar(words.first);
  final last = _firstChar(words.last);

  if (latin) {
    return '${_latinInitial(first)}${_latinInitial(last)}';
  }

  final left = normalizeInitialLetter(first);
  final right = normalizeInitialLetter(last);
  if (left.isEmpty && right.isEmpty) return '—';
  if (left.isEmpty) return right;
  if (right.isEmpty) return left;
  return '$left$officeInitialsSeparator$right';
}

String _firstChar(String word) {
  if (word.isEmpty) return '';
  return String.fromCharCode(word.runes.first);
}

String _latinInitial(String word) {
  if (word.isEmpty) return '';
  final ch = _firstChar(word);
  final code = ch.codeUnitAt(0);
  if (code >= 0x41 && code <= 0x5A) return ch;
  if (code >= 0x61 && code <= 0x7A) return ch.toUpperCase();
  return ch;
}