import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/money/ledger_math.dart';
import 'package:bnood/core/money/money_format.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('engineer profit does not change project balance', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Client');
    final project = (await repo.primaryActiveProject(client.id))!;
    await repo.updateProject(projectId: project.id, engineerBasisPoints: 1000);
    await repo.insertTransaction(
      projectId: project.id,
      kind: 'receive',
      amountPiastres: 1000000,
      date: DateTime(2025, 1, 1),
      method: 'cash',
    );
    await repo.insertTransaction(
      projectId: project.id,
      kind: 'spend',
      amountPiastres: 400000,
      date: DateTime(2025, 1, 2),
      method: 'cash',
      itemId: (await repo.watchActiveItems().first).first.id,
      expenseType: 'materials',
    );
    final bal = await repo.projectBalance(project.id);
    expect(bal.balancePiastres, 600000);
    final profit = MoneyFormat.estimatedProfitPiastres(
      totalSpendPiastres: bal.spentPiastres,
      engineerBasisPoints: 1000,
    );
    expect(profit, 40000);
    expect(
        LedgerMath.projectBalance(await repo.transactionsForProject(project.id))
            .balancePiastres,
        600000);
  });
}
