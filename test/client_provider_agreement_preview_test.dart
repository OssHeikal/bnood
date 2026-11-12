import 'package:bnood/core/agreements/app_agreement_record.dart';
import 'package:bnood/core/clients/client_provider_agreement_preview.dart';
import 'package:bnood/core/providers_api/app_provider_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clientAgreementPreviews filters by provider type', () {
  final agreements = [
    AppAgreement(
      id: 'a1',
      clientId: 'c1',
      providerId: 'craft-1',
      amountPiastres: 100,
      providerType: AppProviderType.craftsman,
      providerName: 'Craft',
    ),
    AppAgreement(
      id: 'a2',
      clientId: 'c1',
      providerId: 'sup-1',
      amountPiastres: null,
      amountMajor: null,
      remainingMajor: null,
      providerType: AppProviderType.supplier,
      providerName: 'Supplier',
    ),
  ];
    final craftsmen = clientAgreementPreviews(agreements, AppProviderType.craftsman);
    final suppliers = clientAgreementPreviews(agreements, AppProviderType.supplier);
    expect(craftsmen, hasLength(1));
    expect(craftsmen.first.craftsmanId, 'craft-1');
    expect(suppliers, hasLength(1));
    expect(suppliers.first.craftsmanId, 'sup-1');
    expect(suppliers.first.remainingPiastres, isNull);
  });

  test('assignments save delete scope respects provider kind', () {
    final agreements = [
      AppAgreement(
        id: 'ag-craft',
        clientId: 'c1',
        providerId: 'craft-1',
        amountPiastres: 100,
        providerType: AppProviderType.craftsman,
      ),
      AppAgreement(
        id: 'ag-supp',
        clientId: 'c1',
        providerId: 'sup-1',
        amountPiastres: 200,
        providerType: AppProviderType.supplier,
      ),
    ];
    const craftsmanRoster = {'craft-1', 'craft-2'};
    const supplierRoster = {'sup-1', 'sup-2'};
    const selectedSuppliers = <String>{'sup-2'};

    final supplierDeletes = clientAgreementsToDeleteOnAssignmentsSave(
      allAgreements: agreements,
      kind: AppProviderType.supplier,
      kindProviderIds: supplierRoster,
      selectedProviderIds: selectedSuppliers,
    ).map((a) => a.id).toList();

    expect(supplierDeletes, ['ag-supp']);
    expect(supplierDeletes, isNot(contains('ag-craft')));

    const selectedCraftsmen = <String>{'craft-2'};
    final craftsmanDeletes = clientAgreementsToDeleteOnAssignmentsSave(
      allAgreements: agreements,
      kind: AppProviderType.craftsman,
      kindProviderIds: craftsmanRoster,
      selectedProviderIds: selectedCraftsmen,
    ).map((a) => a.id).toList();

    expect(craftsmanDeletes, ['ag-craft']);
    expect(craftsmanDeletes, isNot(contains('ag-supp')));
  });

  test('missing provider.type uses roster membership only', () {
    final agreements = [
      AppAgreement(
        id: 'orphan',
        clientId: 'c1',
        providerId: 'unknown-1',
        amountPiastres: 1,
        providerType: null,
      ),
      AppAgreement(
        id: 'in-roster',
        clientId: 'c1',
        providerId: 'craft-1',
        amountPiastres: 2,
        providerType: null,
      ),
    ];

    final craftsmen = clientAgreementPreviews(
      agreements,
      AppProviderType.craftsman,
      kindProviderIds: const {'craft-1'},
    );
    expect(craftsmen.map((r) => r.agreementId), ['in-roster']);

    final deletes = clientAgreementsToDeleteOnAssignmentsSave(
      allAgreements: agreements,
      kind: AppProviderType.supplier,
      kindProviderIds: const {'sup-1'},
      selectedProviderIds: const {},
    );
    expect(deletes.map((a) => a.id), isEmpty);
  });

  test('provider assignments save delete scope is limited to provider agreements', () {
    final mixed = [
      AppAgreement(
        id: 'p1-c1',
        clientId: 'c1',
        providerId: 'prov-a',
        amountPiastres: 1,
        providerType: AppProviderType.craftsman,
      ),
      AppAgreement(
        id: 'p1-c2',
        clientId: 'c2',
        providerId: 'prov-a',
        amountPiastres: 2,
        providerType: AppProviderType.craftsman,
      ),
      AppAgreement(
        id: 'p2-c1',
        clientId: 'c1',
        providerId: 'prov-b',
        amountPiastres: 3,
        providerType: AppProviderType.supplier,
      ),
    ];
    final scoped = agreementsBelongingToProvider(mixed, 'prov-a');
    expect(scoped.map((a) => a.id), ['p1-c1', 'p1-c2']);

    final deletes = providerAgreementsToDeleteOnAssignmentsSave(
      providerAgreements: scoped,
      selectedClientIds: const {'c2'},
    ).map((a) => a.id).toList();

    expect(deletes, ['p1-c1']);
    expect(deletes, isNot(contains('p2-c1')));
  });
}
