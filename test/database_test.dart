import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/core/seed/default_items.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('migration seeds workspace and 16 items', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final ws = await db.requireWorkspaceId();
    expect(ws, isNotEmpty);
    final items = await db.select(db.items).get();
    expect(items.length, defaultItemSeeds.length);
  });

  test('client auto creates project', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Ali');
    final project = await repo.primaryActiveProject(client.id);
    expect(project, isNotNull);
    expect(project!.clientId, client.id);
  });
}
