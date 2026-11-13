import 'package:bnood/core/database/database.dart';
import 'package:bnood/features/clients/client_movements_filters.dart';
import 'package:bnood/features/clients/client_movements_local_filter.dart';
import 'package:flutter_test/flutter_test.dart';

Transaction _tx({
  required String id,
  required DateTime date,
  String kind = 'spend',
  String? itemId,
  String? description,
}) {
  return Transaction(
    id: id,
    workspaceId: 'w',
    projectId: 'p',
    kind: kind,
    amountPiastres: 100,
    date: date,
    method: 'cash',
    description: description,
    itemId: itemId,
    createdAt: date,
    updatedAt: date,
  );
}

void main() {
  test('local filter applies item and search', () {
    final tx = [
      _tx(id: 't1', date: DateTime(2026, 1, 10), itemId: 'i1', description: 'note alpha'),
      _tx(id: 't2', date: DateTime(2026, 1, 5), kind: 'receive'),
      _tx(id: 't3', date: DateTime(2026, 2, 1), itemId: 'i2', description: 'other'),
    ];

    const filters = ClientMovementsFilters(searchQuery: 'alpha', itemId: 'i1');

    final lines = filterLocalMovementLines(
      transactions: tx,
      filters: filters,
      itemById: const {},
      supplierById: const {},
      craftsmanById: const {},
    );

    expect(lines.length, 1);
    expect(lines.first.transaction.id, 't1');
  });

  test('local search is Arabic-insensitive on notes', () {
    final tx = _tx(id: 't4', date: DateTime(2026, 3, 1), description: 'الوميتال');
    final lines = filterLocalMovementLines(
      transactions: [tx],
      filters: const ClientMovementsFilters(searchQuery: 'ألومي'),
      itemById: const {},
      supplierById: const {},
      craftsmanById: const {},
    );
    expect(lines.length, 1);
  });
}
