import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/money/ledger_math.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('craftsmanLaborTransactions exclude materials and receive', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);

    final client = await repo.createClient(name: 'Client');
    final project = (await repo.primaryActiveProject(client.id))!;
    final craftsman = await repo.createCraftsman(name: 'Plumber', phone: '01000000001');
    final item = (await repo.watchActiveItems().first).first;

    await repo.insertTransaction(
      projectId: project.id,
      kind: 'spend',
      amountPiastres: 100_00,
      date: DateTime.utc(2026, 11, 1),
      method: 'cash',
      itemId: item.id,
      expenseType: 'labor',
      craftsmanId: craftsman.id,
    );
    await repo.insertTransaction(
      projectId: project.id,
      kind: 'spend',
      amountPiastres: 200_00,
      date: DateTime.utc(2026, 11, 2),
      method: 'cash',
      itemId: item.id,
      expenseType: 'materials',
      craftsmanId: craftsman.id,
    );
    await repo.insertTransaction(
      projectId: project.id,
      kind: 'receive',
      amountPiastres: 300_00,
      date: DateTime.utc(2026, 11, 3),
      method: 'cash',
      craftsmanId: craftsman.id,
    );

    final rows = await repo.craftsmanLaborTransactions(craftsman.id);
    expect(rows, hasLength(1));
    expect(rows.single.amountPiastres, 100_00);
  });

  test('agreement with zero paid still listed and null vs zero remaining', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);

    final client = await repo.createClient(name: 'Tower');
    final project = (await repo.primaryActiveProject(client.id))!;
    final craftsman = await repo.createCraftsman(name: 'Painter', phone: '01000000002');

    await repo.upsertAgreement(projectId: project.id, craftsmanId: craftsman.id);
    final nullAgreements = await repo.agreementsForCraftsman(craftsman.id);
    expect(nullAgreements, hasLength(1));
    expect(nullAgreements.single.initialAmountPiastres, isNull);

    final tx = await repo.transactionsForProject(project.id);
    final paid = LedgerMath.craftsmanPaidPiastres(rows: tx, craftsmanId: craftsman.id);
    expect(paid, 0);
    expect(
      LedgerMath.craftsmanRemainingPiastres(initialAmountPiastres: null, paidPiastres: paid),
      isNull,
    );

    await repo.upsertAgreement(
      projectId: project.id,
      craftsmanId: craftsman.id,
      initialAmountPiastres: 0,
    );
    expect(
      LedgerMath.craftsmanRemainingPiastres(initialAmountPiastres: 0, paidPiastres: 0),
      0,
    );
  });

  test('labor history includes payment without agreement and archived client', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);

    final client = await repo.createClient(name: 'Archived');
    final project = (await repo.primaryActiveProject(client.id))!;
    final craftsman = await repo.createCraftsman(name: 'Solo', phone: '01000000003');
    final item = (await repo.watchActiveItems().first).first;

    await repo.insertTransaction(
      projectId: project.id,
      kind: 'spend',
      amountPiastres: 400_00,
      date: DateTime.utc(2026, 11, 4),
      method: 'transfer',
      itemId: item.id,
      expenseType: 'labor',
      craftsmanId: craftsman.id,
    );

    var rows = await repo.craftsmanLaborTransactions(craftsman.id);
    expect(rows, hasLength(1));

    await repo.archiveClient(client.id);
    rows = await repo.craftsmanLaborTransactions(craftsman.id);
    expect(rows.single.amountPiastres, 400_00);
    expect((await repo.agreementsForCraftsman(craftsman.id)), isEmpty);
  });

  test('watchCraftsmanDetailSignals fires after agreement upsert', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);

    final client = await repo.createClient(name: 'Signal');
    final project = (await repo.primaryActiveProject(client.id))!;
    final craftsman = await repo.createCraftsman(name: 'Wire', phone: '01000000004');

    var signals = 0;
    final sub = repo.watchCraftsmanDetailSignals(craftsman.id).listen((_) => signals++);
    addTearDown(sub.cancel);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    final initial = signals;

    await repo.upsertAgreement(projectId: project.id, craftsmanId: craftsman.id, initialAmountPiastres: 500_00);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(signals, greaterThan(initial));
  });
}
