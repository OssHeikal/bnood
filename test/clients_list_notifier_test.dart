import 'package:bnood/core/ledger/ledger_entities.dart';
import 'package:bnood/features/home/data/home_row_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bnood/features/clients/presentation/providers/clients_list_providers.dart';

void main() {
  test('HomeClientBalanceRow.hasBalances is false when API returns null balances', () {
    final now = DateTime.utc(2026, 11, 9);
    final row = HomeClientBalanceRow(
      client: Client(
        id: '1',
        workspaceId: 'remote',
        name: 'A',
        createdAt: now,
        updatedAt: now,
      ),
      remainingPiastres: null,
      receivedPiastres: null,
      spentPiastres: null,
    );
    expect(row.hasBalances, isFalse);
  });

  test('ClientsListSnapshot tracks pagination flags', () {
    const snap = ClientsListSnapshot(rows: [], page: 1, total: 60, hasMore: true);
    expect(snap.hasMore, isTrue);
  });
}
