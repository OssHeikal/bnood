import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('deselecting craftsman removes agreement when no payments', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Client');
    final project = (await repo.primaryActiveProject(client.id))!;
    final craftsman = await repo.createCraftsman(name: 'Temp', phone: '01000000003');
    await repo.upsertAgreement(projectId: project.id, craftsmanId: craftsman.id);

    expect(await repo.agreementsForProject(project.id), hasLength(1));

    await repo.removeCraftsmanFromProject(projectId: project.id, craftsmanId: craftsman.id);
    expect(await repo.agreementsForProject(project.id), isEmpty);
  });
}
