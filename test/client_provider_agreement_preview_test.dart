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
}
