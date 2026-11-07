import '../../core/database/database.dart';
import '../../core/money/ledger_math.dart';

class ItemStatementGroup {
  const ItemStatementGroup({
    required this.itemId,
    required this.itemName,
    required this.rows,
    required this.materialsPiastres,
    required this.laborPiastres,
  });

  final String itemId;
  final String itemName;
  final List<Transaction> rows;
  final int materialsPiastres;
  final int laborPiastres;

  int get spentPiastres => materialsPiastres + laborPiastres;
}

List<ItemStatementGroup> groupSpendByItem({
  required List<Transaction> periodSpend,
  required Map<String, String> itemNames,
  required String unspecifiedItemLabel,
}) {
  final byItem = <String, List<Transaction>>{};
  for (final t in periodSpend) {
    byItem.putIfAbsent(t.itemId ?? '', () => []).add(t);
  }
  final breakdown = LedgerMath.itemBreakdown(periodSpend);
  final out = <ItemStatementGroup>[];
  for (final entry in byItem.entries) {
    final id = entry.key;
    final name = id.isEmpty ? unspecifiedItemLabel : (itemNames[id] ?? id);
    final br = breakdown[id] ?? const ItemExpenseBreakdown();
    final rows = List<Transaction>.from(entry.value)
      ..sort((a, b) => a.date.compareTo(b.date));
    out.add(ItemStatementGroup(
      itemId: id,
      itemName: name,
      rows: rows,
      materialsPiastres: br.materialsPiastres,
      laborPiastres: br.laborPiastres,
    ));
  }
  out.sort((a, b) => a.itemName.compareTo(b.itemName));
  return out;
}
