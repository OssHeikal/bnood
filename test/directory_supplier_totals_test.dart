import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('supplier directory totals include spend from archived client projects', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);

    final client = await repo.createClient(name: 'Archived Client');
    final project = await repo.primaryActiveProject(client.id);
    expect(project, isNotNull);
    final supplier = await repo.createSupplier(name: 'Ahmed Steel');
    final item = (await repo.watchActiveItems().first).first;

    await repo.insertTransaction(
      projectId: project!.id,
      kind: 'spend',
      amountPiastres: 250_00,
      date: DateTime.utc(2026, 11, 1),
      method: 'cash',
      itemId: item.id,
      expenseType: 'materials',
      supplierId: supplier.id,
    );

    var rows = await repo.watchDirectorySupplierRows().first;
    expect(rows.singleWhere((r) => r.supplier.id == supplier.id).paidPiastres, 250_00);

    await repo.archiveClient(client.id);

    final home = await repo.homeSupplierSpendsForActiveClients();
    expect(home.any((r) => r.supplier.id == supplier.id), isFalse);

    rows = await repo.watchDirectorySupplierRows().first;
    expect(rows.singleWhere((r) => r.supplier.id == supplier.id).paidPiastres, 250_00);
  });

  test('craftsman directory counts agreements with zero labor paid', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);

    final client = await repo.createClient(name: 'Client A');
    final project = await repo.primaryActiveProject(client.id);
    expect(project, isNotNull);
    final craftsman = await repo.createCraftsman(name: 'Plumber', phone: '01000000001', trade: 'سباكة');

    await repo.upsertAgreement(projectId: project!.id, craftsmanId: craftsman.id);

    final rows = await repo.watchDirectoryCraftsmanRows().first;
    final row = rows.singleWhere((r) => r.craftsman.id == craftsman.id);
    expect(row.projectCount, 1);
    expect(row.paidPiastres, 0);
  });

  test('craftsman labor paid ignores materials spend', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);

    final client = await repo.createClient(name: 'Client B');
    final project = await repo.primaryActiveProject(client.id);
    final craftsman = await repo.createCraftsman(name: 'Painter', phone: '01000000002');
    final item = (await repo.watchActiveItems().first).first;

    await repo.insertTransaction(
      projectId: project!.id,
      kind: 'spend',
      amountPiastres: 100_00,
      date: DateTime.utc(2026, 11, 2),
      method: 'cash',
      itemId: item.id,
      expenseType: 'materials',
      craftsmanId: craftsman.id,
    );
    await repo.insertTransaction(
      projectId: project.id,
      kind: 'spend',
      amountPiastres: 300_00,
      date: DateTime.utc(2026, 11, 3),
      method: 'transfer',
      itemId: item.id,
      expenseType: 'labor',
      craftsmanId: craftsman.id,
    );

    final rows = await repo.watchDirectoryCraftsmanRows().first;
    expect(rows.singleWhere((r) => r.craftsman.id == craftsman.id).paidPiastres, 300_00);
  });

  test('archived supplier excluded from directory stream', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final supplier = await repo.createSupplier(name: 'Ghost');
    await repo.archiveSupplier(supplier.id);
    final rows = await repo.watchDirectorySupplierRows().first;
    expect(rows.any((r) => r.supplier.id == supplier.id), isFalse);
  });
}
