import 'package:bnood/core/database/database.dart';
import 'package:bnood/core/providers/dashboard_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:flutter_test/flutter_test.dart';

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
