/// Encodes multiple receipt paths in the single nullable [receiptImagePath] column.
abstract final class ReceiptImageCodec {
  static const _separator = '\u001e';

  static List<String> decode(String? stored) {
    if (stored == null || stored.trim().isEmpty) return const [];
    if (!stored.contains(_separator)) return [stored];
    return stored.split(_separator).where((p) => p.trim().isNotEmpty).toList(growable: false);
  }

  static String? encode(List<String> paths) {
    final cleaned = paths.map((p) => p.trim()).where((p) => p.isNotEmpty).toList(growable: false);
    if (cleaned.isEmpty) return null;
    if (cleaned.length == 1) return cleaned.first;
    return cleaned.join(_separator);
  }
}
