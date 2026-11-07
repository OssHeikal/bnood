import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('archived supplier excluded from active stream', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final s = await repo.createSupplier(name: 'Steel');
    var active = await repo.watchActiveSuppliers().first;
    expect(active.any((x) => x.id == s.id), isTrue);
    await repo.archiveSupplier(s.id);
    active = await repo.watchActiveSuppliers().first;
    expect(active.any((x) => x.id == s.id), isFalse);
    final tx = await repo.supplierTransactions(s.id);
    expect(tx, isEmpty);
  });
}
