import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('createCraftsman without phone stores empty and returns id', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);

    final craftsman = await repo.createCraftsman(name: 'No Phone');
    expect(craftsman.phone, '');
    expect(craftsman.id, isNotEmpty);

    final listed = await repo.listActiveCraftsmen();
    expect(listed.any((c) => c.id == craftsman.id), isTrue);
  });

  test('createCraftsman with phone preserves digits', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final craftsman = await repo.createCraftsman(name: 'Has Phone', phone: '01012345678');
    expect(craftsman.phone, '01012345678');
  });
}
