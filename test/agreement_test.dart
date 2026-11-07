import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/money/ledger_math.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('agreement null differs from zero and cross-project', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final c1 = await repo.createClient(name: 'A');
    final c2 = await repo.createClient(name: 'B');
    final p1 = (await repo.primaryActiveProject(c1.id))!;
    final p2 = (await repo.primaryActiveProject(c2.id))!;
    final cm = await repo.createCraftsman(name: 'Karim', phone: '0100');
    await repo.upsertAgreement(
        projectId: p1.id, craftsmanId: cm.id, initialAmountPiastres: 800000);
    await repo.upsertAgreement(
        projectId: p2.id, craftsmanId: cm.id, clearInitial: true);
    final a1 = await repo.agreementsForProject(p1.id);
    final a2 = await repo.agreementsForProject(p2.id);
    expect(a1.single.initialAmountPiastres, 800000);
    expect(a2.single.initialAmountPiastres, isNull);
    expect(
      LedgerMath.craftsmanRemainingPiastres(
          initialAmountPiastres: 0, paidPiastres: 0),
      0,
    );
    expect(
        LedgerMath.craftsmanRemainingPiastres(
            initialAmountPiastres: null, paidPiastres: 0),
        isNull);
  });

  test('link-only upsert keeps stored agreement amount', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Client A');
    final project = (await repo.primaryActiveProject(client.id))!;
    final craftsman = await repo.createCraftsman(name: 'Craftsman B', phone: '01000');

    await repo.upsertAgreement(
      projectId: project.id,
      craftsmanId: craftsman.id,
      initialAmountPiastres: 1_000_000,
    );
    await repo.upsertAgreement(
      projectId: project.id,
      craftsmanId: craftsman.id,
    );

    final stored =
        (await repo.agreementsForProject(project.id)).single.initialAmountPiastres;
    expect(stored, 1_000_000);
  });
}
