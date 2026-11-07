import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/vouchers/voucher_draft.dart';
import 'package:bnood/features/vouchers/voucher_draft_enrich.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('enrich fills client and item labels from ids', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Said');
    final project = await repo.primaryActiveProject(client.id);
    expect(project, isNotNull);
    final items = await repo.watchActiveItems().first;
    final item = items.first;

    const draft = VoucherDraft(
      clientId: 'pending',
      itemId: 'pending-item',
      editingTransactionId: 'tx',
    );
    final enriched = await enrichVoucherDraft(
      repo,
      draft.copyWith(clientId: client.id, itemId: item.id, projectId: project!.id),
    );

    expect(enriched.clientLabel, 'Said');
    expect(enriched.itemLabel, item.name);
  });
}
