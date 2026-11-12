import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/vouchers/voucher_draft.dart';
import 'package:bnood/features/vouchers/voucher_provider_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('providerMatchesDraftLink distinguishes labor vs materials provider id', () {
    const labor = VoucherDraft(
      kind: 'spend',
      expenseType: 'labor',
      craftsmanId: 'c1',
    );
    const materials = VoucherDraft(
      kind: 'spend',
      expenseType: 'materials',
      supplierId: 's1',
    );
    expect(providerMatchesDraftLink(labor, 'c1'), isTrue);
    expect(providerMatchesDraftLink(labor, 's1'), isFalse);
    expect(providerMatchesDraftLink(materials, 's1'), isTrue);
    expect(providerMatchesDraftLink(materials, 'c1'), isFalse);
  });

  test('ensureLocalVoucherProviderAgreement links unlinked craftsman', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'عميل');
    final project = (await repo.primaryActiveProject(client.id))!;
    final item = (await repo.watchActiveItems().first).first;
    final craftsman = await repo.createCraftsman(name: 'مصنعية');

    const draft = VoucherDraft(
      clientId: 'ignored',
      projectId: 'p',
      kind: 'spend',
      expenseType: 'labor',
      itemId: 'i',
      craftsmanId: 'cr',
      providerLinkedToClient: false,
    );
    await ensureLocalVoucherProviderAgreement(
      repo: repo,
      draft: draft.copyWith(clientId: client.id, projectId: project.id, craftsmanId: craftsman.id, itemId: item.id),
      agreementAmountPiastres: null,
    );

    final agreements = await repo.agreementsForProject(project.id);
    expect(agreements.any((a) => a.craftsmanId == craftsman.id), isTrue);
    expect(
      agreements.firstWhere((a) => a.craftsmanId == craftsman.id).initialAmountPiastres,
      isNull,
    );
  });

  test('ensureLocalVoucherProviderAgreement skips when already linked', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'عميل');
    final project = (await repo.primaryActiveProject(client.id))!;
    final craftsman = await repo.createCraftsman(name: 'مربوط');
    await repo.upsertAgreement(projectId: project.id, craftsmanId: craftsman.id, initialAmountPiastres: 10_000);

    await ensureLocalVoucherProviderAgreement(
      repo: repo,
      draft: VoucherDraft(
        clientId: client.id,
        projectId: project.id,
        kind: 'spend',
        expenseType: 'labor',
        craftsmanId: craftsman.id,
        providerLinkedToClient: true,
      ),
      agreementAmountPiastres: 50_000,
    );

    final agreements = await repo.agreementsForProject(project.id);
    expect(agreements.length, 1);
    expect(agreements.single.initialAmountPiastres, 10_000);
  });

}
