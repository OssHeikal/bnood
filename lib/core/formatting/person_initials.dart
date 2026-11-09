String personInitials(String? name) {
  final trimmed = name?.trim();
  if (trimmed == null || trimmed.isEmpty) return '?';
  final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    return _initialGlyph(parts.first);
  }
  return '${_initialGlyph(parts.first)}${_initialGlyph(parts[1])}';
}

String _initialGlyph(String word) {
  if (word.isEmpty) return '?';
  final ch = String.fromCharCode(word.runes.first);
  final code = ch.codeUnitAt(0);
  if (code >= 0x41 && code <= 0x5A) return ch;
  if (code >= 0x61 && code <= 0x7A) return ch.toUpperCase();
  return ch;
}
