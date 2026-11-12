import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../core/api/api_error_user_message.dart';
import '../../core/api/auth_api_exception.dart';
import '../../core/validation/egypt_mobile_phone_validation.dart';
import '../../core/providers_api/app_provider_record.dart';
import '../../core/providers_api/providers_error_handler.dart';
import '../../core/providers_api/providers_riverpod.dart';
import '../../core/shared/pagination/paging_refresh.dart';
import '../../core/widgets/app_decision.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/toast/app_tone.dart';

void refreshAfterProviderMutation(WidgetRef ref) {
  bumpPagingListRefresh(ref, PagingListIds.providers);
}

Future<AppProvider?> saveProviderCreate({
  required WidgetRef ref,
  required BuildContext context,
  required String name,
  required AppProviderType type,
  String? phone,
}) async {
  final repo = ref.read(appProvidersRepositoryProvider);
  try {
    final provider = await repo.createProvider(name: name, type: type, phone: egyptMobileForApi(phone));
    refreshAfterProviderMutation(ref);
    return provider;
  } on AuthApiException catch (e) {
    if (!context.mounted) return null;
    if (await handleProvidersApiAuthError(context: context, ref: ref, error: e)) {
      return null;
    }
    if (e.isDuplicateName || e.isDuplicatePhone) rethrow;
    AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    return null;
  }
}

Future<AppProvider?> saveProviderUpdate({
  required WidgetRef ref,
  required BuildContext context,
  required String providerId,
  required String name,
  required String phoneField,
}) async {
  final repo = ref.read(appProvidersRepositoryProvider);
  final normalized = egyptMobileForApi(phoneField);
  final clearPhone = normalized == null;
  try {
    final provider = await repo.updateProvider(
      id: providerId,
      name: name,
      phone: clearPhone ? null : normalized,
      clearPhone: clearPhone,
    );
    refreshAfterProviderMutation(ref);
    return provider;
  } on AuthApiException catch (e) {
    if (!context.mounted) return null;
    if (await handleProvidersApiAuthError(context: context, ref: ref, error: e)) {
      return null;
    }
    if (e.isDuplicateName || e.isDuplicatePhone) rethrow;
    AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    return null;
  }
}

Future<bool> confirmDeleteProvider(
  BuildContext context,
  WidgetRef ref, {
  required String providerId,
  required String name,
}) async {
  final l10n = AppLocalizations.of(context);
  final answer = await AppDecision.show(
    context,
    title: l10n.deleteProviderTitle,
    description: l10n.deleteProviderDescription(name),
    confirmLabel: l10n.delete,
    cancelLabel: l10n.cancel,
    tone: AppTone.danger,
    iconWidget: AppDecision.archiveDangerIcon(context),
  );
  if (answer != OverlayAnswer.confirmed) return false;
  final repo = ref.read(appProvidersRepositoryProvider);
  try {
    await repo.deleteProvider(providerId);
    refreshAfterProviderMutation(ref);
    return true;
  } on AuthApiException catch (e) {
    if (!context.mounted) return false;
    if (await handleProvidersApiAuthError(context: context, ref: ref, error: e)) {
      return false;
    }
    AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    return false;
  }
}

String? duplicateProviderNameFieldError(AppLocalizations l10n, AuthApiException error) {
  if (error.isDuplicateName) return l10n.providerDuplicateNameError;
  return null;
}

String? duplicateProviderPhoneFieldError(AppLocalizations l10n, AuthApiException error) {
  if (error.isDuplicatePhone) return l10n.providerDuplicatePhoneError;
  return null;
}
