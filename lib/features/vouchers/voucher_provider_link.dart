import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/auth_api_exception.dart';
import '../../core/agreements/agreement_amount_api.dart';
import '../../core/agreements/agreements_riverpod.dart';
import 'voucher_draft.dart';

Future<Set<String>> linkedProviderIdsForClient(
  WidgetRef ref,
  String clientId,
) async {
  final agreements = await ref.read(appAgreementsRepositoryProvider).listAllClientAgreements(clientId);
  return agreements.map((a) => a.providerId).toSet();
}

bool providerMatchesDraftLink(VoucherDraft draft, String providerId) {
  if (draft.expenseType == 'labor') return draft.craftsmanId == providerId;
  if (draft.expenseType == 'materials') return draft.supplierId == providerId;
  return false;
}

Future<void> ensureVoucherProviderAgreementBeforeSave({
  required WidgetRef ref,
  required VoucherDraft draft,
  required int? agreementAmountPiastres,
}) async {
  if (draft.kind != 'spend' || draft.clientId == null) return;
  if (draft.providerLinkedToClient == true) return;

  final providerId =
      draft.expenseType == 'labor' ? draft.craftsmanId : draft.supplierId;
  if (providerId == null) return;

  try {
    await ref.read(appAgreementsRepositoryProvider).createAgreement(
          clientId: draft.clientId!,
          providerId: providerId,
          amountMajor: agreementAmountMajorFromMinor(agreementAmountPiastres),
          omitAmount: agreementAmountPiastres == null,
        );
  } on AuthApiException catch (e) {
    if (!e.isAlreadyLinked) rethrow;
  }
}
