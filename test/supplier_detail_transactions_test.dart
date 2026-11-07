import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('supplierTransactions are spend-only across archived projects', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);

    final client = await repo.createClient(name: 'Client');
    final project = (await repo.primaryActiveProject(client.id))!;
    final supplier = await repo.createSupplier(name: 'Vendor');
    final item = (await repo.watchActiveItems().first).first;

    await repo.insertTransaction(
      projectId: project.id,
      kind: 'spend',
      amountPiastres: 100_00,
      date: DateTime.utc(2026, 11, 1),
      method: 'cash',
      itemId: item.id,
      expenseType: 'materials',
      supplierId: supplier.id,
    );
    await repo.insertTransaction(
      projectId: project.id,
      kind: 'receive',
      amountPiastres: 500_00,
      date: DateTime.utc(2026, 11, 2),
      method: 'cash',
      supplierId: supplier.id,
    );

    var rows = await repo.supplierTransactions(supplier.id);
    expect(rows, hasLength(1));
    expect(rows.single.amountPiastres, 100_00);

    await repo.archiveClient(client.id);

    rows = await repo.supplierTransactions(supplier.id);
    expect(rows, hasLength(1));
    expect(rows.single.amountPiastres, 100_00);

    final info = await repo.clientInfoForProjectIds([project.id]);
    expect(info[project.id]?.clientName, 'Client');
  });

  test('watchSupplierSpendTransactions emits after insert', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);

    final client = await repo.createClient(name: 'Live Client');
    final project = (await repo.primaryActiveProject(client.id))!;
    final supplier = await repo.createSupplier(name: 'Reactive Vendor');
    final item = (await repo.watchActiveItems().first).first;

    final stream = repo.watchSupplierSpendTransactions(supplier.id);
    final events = <List<dynamic>>[];
    final sub = stream.listen(events.add);
    addTearDown(sub.cancel);

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(events.last, isEmpty);

    await repo.insertTransaction(
      projectId: project.id,
      kind: 'spend',
      amountPiastres: 75_00,
      date: DateTime.utc(2026, 11, 3),
      method: 'transfer',
      itemId: item.id,
      expenseType: 'materials',
      supplierId: supplier.id,
    );

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(events.last, hasLength(1));
    expect(events.last.single.amountPiastres, 75_00);
  });
}
