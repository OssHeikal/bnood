import 'dart:typed_data';

class ClientStatementPdf {
  const ClientStatementPdf({
    required this.bytes,
    required this.fileName,
  });

  final Uint8List bytes;
  final String fileName;
}

/// Parses `Content-Disposition` filename for statement PDF downloads.
String? clientStatementPdfFileNameFromHeader(String? contentDisposition) {
  if (contentDisposition == null || contentDisposition.isEmpty) return null;
  final quoted = RegExp(r'''filename\s*=\s*"([^"]+)"''', caseSensitive: false).firstMatch(contentDisposition);
  if (quoted != null) return quoted.group(1);
  final plain = RegExp(r'''filename\s*=\s*([^;]+)''', caseSensitive: false).firstMatch(contentDisposition);
  final raw = plain?.group(1)?.trim();
  if (raw == null || raw.isEmpty) return null;
  return raw.replaceAll('"', '');
}
