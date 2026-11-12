import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/auth_api_exception.dart';
import '../../core/agreements/agreement_amount_api.dart';
import '../../core/agreements/agreements_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/vouchers/vouchers_riverpod.dart';
import '../../core/repositories/bnood_repository.dart';
import 'voucher_draft.dart';

Future<Set<String>> linkedProviderIdsForClient(
  WidgetRef ref,
  String clientId, {
  required bool remote,
}) async {
  if (remote) {
    final agreements = await ref.read(appAgreementsRepositoryProvider).listAllClientAgreements(clientId);
    return agreements.map((a) => a.providerId).toSet();
  }
  final project = await ref.read(repositoryProvider).primaryProjectForClient(clientId);
  if (project == null) return const {};
  final agreements = await ref.read(repositoryProvider).agreementsForProject(project.id);
  return agreements.map((a) => a.craftsmanId).toSet();
}

Future<Set<String>> linkedCraftsmanIdsForProject(WidgetRef ref, String projectId) async {
  final agreements = await ref.read(repositoryProvider).agreementsForProject(projectId);
  return agreements.map((a) => a.craftsmanId).toSet();
}

bool providerMatchesDraftLink(VoucherDraft draft, String providerId) {
  if (draft.expenseType == 'labor') return draft.craftsmanId == providerId;
  if (draft.expenseType == 'materials') return draft.supplierId == providerId;
  return false;
}

Future<void> ensureLocalVoucherProviderAgreement({
  required BnoodRepository repo,
  required VoucherDraft draft,
  required int? agreementAmountPiastres,
}) async {
  if (draft.kind != 'spend' || draft.clientId == null) return;
  if (draft.providerLinkedToClient == true) return;
  final providerId =
      draft.expenseType == 'labor' ? draft.craftsmanId : draft.supplierId;
  if (providerId == null) return;
  if (draft.expenseType != 'labor' || draft.projectId == null) return;

  if (agreementAmountPiastres != null) {
    await repo.upsertAgreement(
      projectId: draft.projectId!,
      craftsmanId: providerId,
      initialAmountPiastres: agreementAmountPiastres,
    );
  } else {
    await repo.ensureProjectCraftsmanLink(
      projectId: draft.projectId!,
      craftsmanId: providerId,
    );
  }
}

Future<void> ensureVoucherProviderAgreementBeforeSave({
  required WidgetRef ref,
  required VoucherDraft draft,
  required int? agreementAmountPiastres,
}) async {
  if (draft.kind != 'spend' || draft.clientId == null) return;
  if (draft.providerLinkedToClient == true) return;

  final remote = ref.read(remoteVouchersEnabledProvider);
  final providerId =
      draft.expenseType == 'labor' ? draft.craftsmanId : draft.supplierId;
  if (providerId == null) return;

  if (remote) {
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
    return;
  }

  await ensureLocalVoucherProviderAgreement(
    repo: ref.read(repositoryProvider),
    draft: draft,
    agreementAmountPiastres: agreementAmountPiastres,
  );
}
