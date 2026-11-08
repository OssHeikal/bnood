import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home craftsmen ranked by most recent labor transaction', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final older = await repo.createCraftsman(name: 'قديم');
    final newer = await repo.createCraftsman(name: 'جديد');
    final client = await repo.createClient(name: 'عميل');
    final project = (await repo.primaryActiveProject(client.id))!;
    final item = (await repo.watchActiveItems().first).first;

    await repo.insertTransaction(
      projectId: project.id,
      kind: 'spend',
      amountPiastres: 10000,
      date: DateTime(2025, 1, 10),
      method: 'cash',
      itemId: item.id,
      expenseType: 'labor',
      craftsmanId: older.id,
    );
    await repo.insertTransaction(
      projectId: project.id,
      kind: 'spend',
      amountPiastres: 20000,
      date: DateTime(2025, 3, 1),
      method: 'cash',
      itemId: item.id,
      expenseType: 'labor',
      craftsmanId: newer.id,
    );

    final rows = await repo.homeCraftsmenByRecentLabor();
    expect(rows.length, 2);
    expect(rows.first.craftsman.id, newer.id);
    expect(rows.first.paidPiastres, 20000);
    expect(rows.first.remainingPiastres, isNull);
    expect(rows.last.paidPiastres, 10000);
    expect(rows.last.remainingPiastres, isNull);
  });

  test('home craftsman remaining sums set agreements on active projects', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final craftsman = await repo.createCraftsman(name: 'صنايعي');
    final clientA = await repo.createClient(name: 'أ');
    final clientB = await repo.createClient(name: 'ب');
    final projectA = (await repo.primaryActiveProject(clientA.id))!;
    final projectB = (await repo.primaryActiveProject(clientB.id))!;
    final item = (await repo.watchActiveItems().first).first;

    await repo.insertTransaction(
      projectId: projectA.id,
      kind: 'spend',
      amountPiastres: 30000,
      date: DateTime(2025, 2, 1),
      method: 'cash',
      itemId: item.id,
      expenseType: 'labor',
      craftsmanId: craftsman.id,
    );
    await repo.insertTransaction(
      projectId: projectB.id,
      kind: 'spend',
      amountPiastres: 10000,
      date: DateTime(2025, 3, 1),
      method: 'cash',
      itemId: item.id,
      expenseType: 'labor',
      craftsmanId: craftsman.id,
    );
    await repo.upsertAgreement(
      projectId: projectA.id,
      craftsmanId: craftsman.id,
      initialAmountPiastres: 80000,
    );
    await repo.upsertAgreement(projectId: projectB.id, craftsmanId: craftsman.id);

    final open = await repo.homeCraftsmenByRecentLabor();
    expect(open.single.remainingPiastres, 50000);

    await repo.upsertAgreement(
      projectId: projectB.id,
      craftsmanId: craftsman.id,
      initialAmountPiastres: 20000,
    );
    final both = await repo.homeCraftsmenByRecentLabor();
    expect(both.single.remainingPiastres, 60000);

    await repo.archiveClient(clientA.id);
    final archived = await repo.homeCraftsmenByRecentLabor();
    expect(archived.single.remainingPiastres, 10000);
  });
}
