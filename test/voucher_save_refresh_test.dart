import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/providers/dashboard_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('silent home balances refresh after insert reflects new remaining', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Hana');
    final project = await repo.primaryActiveProject(client.id);
    expect(project, isNotNull);

    final container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    await container.read(homeClientBalancesProvider.future);

    await repo.insertTransaction(
      projectId: project!.id,
      kind: 'receive',
      amountPiastres: 50_000,
      date: DateTime(2026, 5, 1),
      method: 'cash',
    );

    await container.read(homeClientBalancesProvider.notifier).refreshSilently();
    final rows = await container.read(homeClientBalancesProvider.future);
    final row = rows.firstWhere((r) => r.client.id == client.id);
    expect(row.remainingPiastres, 50_000);
  });
}
