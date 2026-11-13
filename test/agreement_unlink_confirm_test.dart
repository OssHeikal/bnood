import 'package:flutter/material.dart';

import 'package:bnood/core/agreements/app_agreement_record.dart';
import 'package:bnood/core/providers_api/app_provider_record.dart';
import 'package:bnood/features/clients/agreement_mutation_actions.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

AppAgreement _agreement({double? paidMajor}) {
  return AppAgreement(
    id: 'ag-1',
    clientId: 'client-1',
    providerId: 'prov-1',
    amountPiastres: null,
    paidMajor: paidMajor,
  );
}

void main() {
  test('unlink confirm variant is payments guard or plain, never both', () {
    expect(
      agreementUnlinkConfirmVariant(_agreement(paidMajor: 1)),
      AgreementUnlinkConfirmVariant.paymentsGuard,
    );
    expect(
      agreementUnlinkConfirmVariant(_agreement()),
      AgreementUnlinkConfirmVariant.plain,
    );
    expect(
      agreementUnlinkConfirmVariant(_agreement(paidMajor: 0)),
      AgreementUnlinkConfirmVariant.plain,
    );
  });

  test('plain unlink dialog copy uses supplier vs craftsman wording', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final ar = await AppLocalizations.delegate.load(const Locale('ar'));

    final enSupplier = plainUnlinkDialogCopy(
      l10n: en,
      providerType: AppProviderType.supplier,
      partyName: 'Steel Co',
    );
    expect(enSupplier.title, 'Unlink supplier?');
    expect(enSupplier.description, contains('Steel Co'));

    final enCraftsman = plainUnlinkDialogCopy(
      l10n: en,
      providerType: AppProviderType.craftsman,
      partyName: 'Ali',
    );
    expect(enCraftsman.title, 'Unlink craftsman?');
    expect(enCraftsman.description, contains('Ali'));

    final arSupplier = plainUnlinkDialogCopy(
      l10n: ar,
      providerType: AppProviderType.supplier,
      partyName: 'حديد',
    );
    expect(arSupplier.title, 'إلغاء ربط المورد؟');

    final arCraftsman = plainUnlinkDialogCopy(
      l10n: ar,
      providerType: AppProviderType.craftsman,
      partyName: 'علي',
    );
    expect(arCraftsman.title, 'إلغاء ربط الصنايعي؟');
  });
}
