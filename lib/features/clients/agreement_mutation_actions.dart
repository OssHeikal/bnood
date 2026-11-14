import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../core/agreements/app_agreement_record.dart';
import '../../core/agreements/agreements_error_handler.dart';
import '../../core/agreements/agreement_amount_api.dart';
import '../../core/agreements/agreements_riverpod.dart';
import '../../core/api/api_error_user_message.dart';
import '../../core/api/auth_api_exception.dart';
import '../../core/providers_api/app_provider_record.dart';
import '../../core/widgets/app_decision.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/toast/app_tone.dart';
import '../../core/providers/dashboard_providers.dart';
import '../providers/provider_detail_provider.dart';

/// Which unlink confirmation surface to show before delete (never both).
enum AgreementUnlinkConfirmVariant { paymentsGuard, plain }

AgreementUnlinkConfirmVariant agreementUnlinkConfirmVariant(AppAgreement agreement) {
  return agreement.paidMinorForDisplay > 0
      ? AgreementUnlinkConfirmVariant.paymentsGuard
      : AgreementUnlinkConfirmVariant.plain;
}

class AgreementPlainUnlinkDialogCopy {
  const AgreementPlainUnlinkDialogCopy({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

AgreementPlainUnlinkDialogCopy plainUnlinkDialogCopy({
  required AppLocalizations l10n,
  required AppProviderType providerType,
  required String partyName,
}) {
  return switch (providerType) {
    AppProviderType.supplier => AgreementPlainUnlinkDialogCopy(
        title: l10n.agreementUnlinkSupplierTitle,
        description: l10n.agreementUnlinkSupplierDescription(partyName),
      ),
    AppProviderType.craftsman => AgreementPlainUnlinkDialogCopy(
        title: l10n.agreementUnlinkTitle,
        description: l10n.agreementUnlinkDescription(partyName),
      ),
  };
}

Future<bool> confirmPaidBeforeUnlinkIfNeeded({
  required BuildContext context,
  required AppAgreement agreement,
  required String paidGuardClientName,
}) async {
  if (agreement.paidMinorForDisplay <= 0) return true;
  final l10n = AppLocalizations.of(context);
  final paidAnswer = await AppDecision.show(
    context,
    title: l10n.agreementUnlinkClientHasPaymentsTitle,
    description: l10n.agreementUnlinkClientHasPaymentsDescription(paidGuardClientName),
    confirmLabel: l10n.unlink,
    cancelLabel: l10n.cancel,
    tone: AppTone.danger,
  );
  return paidAnswer == OverlayAnswer.confirmed;
}

Future<bool> confirmPlainUnlinkAgreement({
  required BuildContext context,
  required AppProviderType providerType,
  required String partyName,
}) async {
  final l10n = AppLocalizations.of(context);
  final copy = plainUnlinkDialogCopy(
    l10n: l10n,
    providerType: providerType,
    partyName: partyName,
  );
  final answer = await AppDecision.show(
    context,
    title: copy.title,
    description: copy.description,
    confirmLabel: l10n.unlink,
    cancelLabel: l10n.cancel,
    tone: AppTone.danger,
  );
  return answer == OverlayAnswer.confirmed;
}

Future<bool> confirmUnlinkAgreementWithPaidGuard({
  required BuildContext context,
  required WidgetRef ref,
  required AppAgreement agreement,
  required String paidGuardClientName,
  required String unlinkDialogPartyName,
  required AppProviderType providerType,
  String? clientId,
  String? providerId,
}) async {
  final confirmed = switch (agreementUnlinkConfirmVariant(agreement)) {
    AgreementUnlinkConfirmVariant.paymentsGuard => await confirmPaidBeforeUnlinkIfNeeded(
        context: context,
        agreement: agreement,
        paidGuardClientName: paidGuardClientName,
      ),
    AgreementUnlinkConfirmVariant.plain => await confirmPlainUnlinkAgreement(
        context: context,
        providerType: providerType,
        partyName: unlinkDialogPartyName,
      ),
  };
  if (!confirmed) return false;
  return executeUnlinkAgreement(
    context: context,
    ref: ref,
    agreementId: agreement.id,
    clientId: clientId,
    providerId: providerId,
  );
}

Future<bool> confirmUnlinkAgreement({
  required BuildContext context,
  required WidgetRef ref,
  required String agreementId,
  required String partyName,
  required AppProviderType providerType,
  String? clientId,
  String? providerId,
}) async {
  if (!await confirmPlainUnlinkAgreement(
    context: context,
    providerType: providerType,
    partyName: partyName,
  )) {
    return false;
  }
  return executeUnlinkAgreement(
    context: context,
    ref: ref,
    agreementId: agreementId,
    clientId: clientId,
    providerId: providerId,
  );
}

Future<bool> executeUnlinkAgreement({
  required BuildContext context,
  required WidgetRef ref,
  required String agreementId,
  String? clientId,
  String? providerId,
}) async {
  final l10n = AppLocalizations.of(context);
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
    AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
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
  final l10n = AppLocalizations.of(context);
  final repo = ref.read(appAgreementsRepositoryProvider);
  try {
    await repo.patchAgreement(id: agreementId, amountMajor: agreementAmountMajorFromMinor(amountPiastres));
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
      AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
      return false;
    }
    AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    return false;
  }
}
