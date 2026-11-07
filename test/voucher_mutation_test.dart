import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:drift/drift.dart' hide Column, isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('updateTransaction changes amount without inserting duplicate', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Nour');
    final project = await repo.primaryActiveProject(client.id);
    expect(project, isNotNull);

    final inserted = await repo.insertTransaction(
      projectId: project!.id,
      kind: 'receive',
      amountPiastres: 10_000,
      date: DateTime(2026, 1, 1),
      method: 'cash',
    );

    await repo.updateTransaction(
      inserted.id,
      TransactionsCompanion(amountPiastres: const Value(25_000)),
    );

    final rows = await repo.transactionsForProject(project.id);
    expect(rows.length, 1);
    expect(rows.single.id, inserted.id);
    expect(rows.single.amountPiastres, 25_000);
  });
}
