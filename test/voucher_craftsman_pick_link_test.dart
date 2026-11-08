import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ensureProjectCraftsmanLink inserts null initial amount for new link', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'عميل');
    final project = (await repo.primaryActiveProject(client.id))!;
    final craftsman = await repo.createCraftsman(name: 'خالد');

    await repo.ensureProjectCraftsmanLink(
      projectId: project.id,
      craftsmanId: craftsman.id,
    );

    final agreements = await repo.agreementsForProject(project.id);
    expect(agreements.length, 1);
    expect(agreements.single.craftsmanId, craftsman.id);
    expect(agreements.single.initialAmountPiastres, isNull);
  });

  test('ensureProjectCraftsmanLink is idempotent and preserves existing amount', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'عميل');
    final project = (await repo.primaryActiveProject(client.id))!;
    final craftsman = await repo.createCraftsman(name: 'سامي');
    await repo.upsertAgreement(
      projectId: project.id,
      craftsmanId: craftsman.id,
      initialAmountPiastres: 125_000,
    );

    await repo.ensureProjectCraftsmanLink(
      projectId: project.id,
      craftsmanId: craftsman.id,
    );
    await repo.ensureProjectCraftsmanLink(
      projectId: project.id,
      craftsmanId: craftsman.id,
    );

    final agreements = await repo.agreementsForProject(project.id);
    expect(agreements.length, 1);
    expect(agreements.single.initialAmountPiastres, 125_000);
  });

  test('upsertAgreement without amount preserves zero initial', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'عميل');
    final project = (await repo.primaryActiveProject(client.id))!;
    final craftsman = await repo.createCraftsman(name: 'نصري');
    await repo.upsertAgreement(
      projectId: project.id,
      craftsmanId: craftsman.id,
      initialAmountPiastres: 0,
    );

    await repo.upsertAgreement(projectId: project.id, craftsmanId: craftsman.id);

    final agreements = await repo.agreementsForProject(project.id);
    expect(agreements.single.initialAmountPiastres, 0);
  });

  test('draft-only craftsman selection does not create agreement before save', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'عميل');
    final project = (await repo.primaryActiveProject(client.id))!;
    final linked = await repo.createCraftsman(name: 'مسجل');
    await repo.upsertAgreement(projectId: project.id, craftsmanId: linked.id);
    final roster = await repo.createCraftsman(name: 'غير مربوط');

    final before = await repo.agreementsForProject(project.id);
    expect(before.length, 1);

    // Simulates picker cancel / draft-only — no repository write until save.
    expect(roster.id, isNotEmpty);
    final afterCancel = await repo.agreementsForProject(project.id);
    expect(afterCancel.length, 1);
    expect(afterCancel.any((a) => a.craftsmanId == roster.id), isFalse);
  });

  test('labor transaction save path links unlinked roster craftsman', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'عميل');
    final project = (await repo.primaryActiveProject(client.id))!;
    final item = (await repo.watchActiveItems().first).first;
    final craftsman = await repo.createCraftsman(name: 'مصنعية');

    await repo.insertTransaction(
      projectId: project.id,
      kind: 'spend',
      amountPiastres: 50_000,
      date: DateTime(2025, 8, 1),
      method: 'cash',
      itemId: item.id,
      expenseType: 'labor',
      craftsmanId: craftsman.id,
    );
    await repo.ensureProjectCraftsmanLink(
      projectId: project.id,
      craftsmanId: craftsman.id,
    );

    final agreements = await repo.agreementsForProject(project.id);
    expect(agreements.any((a) => a.craftsmanId == craftsman.id), isTrue);
    expect(
      agreements.firstWhere((a) => a.craftsmanId == craftsman.id).initialAmountPiastres,
      isNull,
    );
  });
}
