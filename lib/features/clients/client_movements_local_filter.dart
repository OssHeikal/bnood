import '../../core/database/database.dart' show Transaction, Item, Supplier, CraftsmenData;
import 'client_detail_snapshot.dart';
import 'client_movement_lines.dart';
import 'client_movements_filters.dart';

List<ClientDetailMovementLine> filterLocalMovementLines({
  required List<Transaction> transactions,
  required ClientMovementsFilters filters,
  required Map<String, Item> itemById,
  required Map<String, Supplier> supplierById,
  required Map<String, CraftsmenData> craftsmanById,
}) {
  Iterable<Transaction> rows = transactions;

  if (filters.hasItemFilter) {
    rows = rows.where((t) => t.kind == 'spend' && t.itemId == filters.itemId);
  }

  final from = filters.from;
  if (from != null) {
    final start = DateTime(from.year, from.month, from.day);
    rows = rows.where((t) => !t.date.isBefore(start));
  }

  final to = filters.to;
  if (to != null) {
    final end = DateTime(to.year, to.month, to.day, 23, 59, 59, 999);
    rows = rows.where((t) => !t.date.isAfter(end));
  }

  final q = filters.searchQuery.trim().toLowerCase();
  if (q.isNotEmpty) {
    rows = rows.where((t) => (t.description ?? '').toLowerCase().contains(q));
  }

  final sorted = rows.toList()
    ..sort(
      (a, b) => filters.sort == ClientMovementsSort.dateAsc
          ? a.date.compareTo(b.date)
          : b.date.compareTo(a.date),
    );

  return movementLinesFromTransactions(
    sorted,
    itemById: itemById,
    supplierById: supplierById,
    craftsmanById: craftsmanById,
  );
}
