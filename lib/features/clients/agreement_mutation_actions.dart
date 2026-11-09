import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../core/agreements/agreements_error_handler.dart';
import '../../core/agreements/agreement_amount_api.dart';
import '../../core/agreements/agreements_riverpod.dart';
import '../../core/api/auth_api_exception.dart';
import '../../core/widgets/app_decision.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/toast/app_tone.dart';
import '../../core/providers/dashboard_providers.dart';
import '../providers/provider_detail_provider.dart';

Future<bool> confirmUnlinkAgreement({
  required BuildContext context,
  required WidgetRef ref,
  required String agreementId,
  required String craftsmanName,
  String? clientId,
  String? providerId,
}) async {
  final l10n = AppLocalizations.of(context);
  final answer = await AppDecision.show(
    context,
    title: l10n.agreementUnlinkTitle,
    description: l10n.agreementUnlinkDescription(craftsmanName),
    confirmLabel: l10n.unlink,
    cancelLabel: l10n.cancel,
    tone: AppTone.danger,
  );
  if (answer != OverlayAnswer.confirmed) return false;
  final repo = ref.read(appAgreementsRepositoryProvider);
  try {
    await repo.deleteAgreement(agreementId);
    if (clientId != null) {
      refreshAfterClientMutation(ref, clientId: clientId);
    }
    if (providerId != null) {
      await ref.read(providerDetailProvider(providerId).notifier).refreshSilently();
    }
    return true;
  } on AuthApiException catch (e) {
    if (!context.mounted) return false;
    if (await handleAgreementsApiAuthError(context: context, ref: ref, error: e)) {
      return false;
    }
    AppToaster.show(e.message, kind: ToastKind.failure);
    return false;
  }
}

Future<bool> saveRemoteAgreementAmount({
  required BuildContext context,
  required WidgetRef ref,
  required String agreementId,
  required int? amountPiastres,
  String? clientId,
  String? providerId,
}) async {
  final repo = ref.read(appAgreementsRepositoryProvider);
  try {
    await repo.patchAgreement(
      id: agreementId,
      amountMajor: agreementAmountMajorFromMinor(amountPiastres),
    );
    if (clientId != null) {
      refreshAfterClientMutation(ref, clientId: clientId);
    }
    if (providerId != null) {
      ref.read(providerDetailProvider(providerId).notifier).refreshSilently();
    }
    return true;
  } on AuthApiException catch (e) {
    if (!context.mounted) return false;
    if (await handleAgreementsApiAuthError(context: context, ref: ref, error: e)) {
      return false;
    }
    if (e.isClientArchivedAgreement) {
      AppToaster.show(e.message, kind: ToastKind.failure);
      return false;
    }
    AppToaster.show(e.message, kind: ToastKind.failure);
    return false;
  }
}
