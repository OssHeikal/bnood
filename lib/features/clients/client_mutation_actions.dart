import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bnood/l10n/app_localizations.dart';
import '../../core/api/api_error_user_message.dart';
import '../../core/api/auth_api_exception.dart';
import '../../core/validation/egypt_mobile_phone_validation.dart';
import '../../core/clients/clients_error_handler.dart';
import '../../core/clients/clients_providers.dart';
import '../../core/ledger/ledger_entities.dart';
import '../../core/providers/dashboard_providers.dart';
import '../../core/widgets/app_decision.dart';
import '../../core/analytics/providers/analytics_feature_hooks.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/toast/app_tone.dart';
import '../subscription/subscription_error_handler.dart';
import '../subscription/subscription_gates.dart';

Future<Client?> saveClientCreate({
  required WidgetRef ref,
  required BuildContext context,
  required String name,
  String? phone,
}) async {
  final l10n = AppLocalizations.of(context);
  return _saveRemoteCreate(ref, context, l10n, name: name, phone: phone);
}

Future<Client?> saveClientUpdate({
  required WidgetRef ref,
  required BuildContext context,
  required String clientId,
  required String name,
  required String phoneField,
}) async {
  final l10n = AppLocalizations.of(context);
  return _saveRemoteUpdate(
    ref,
    context,
    l10n,
    clientId: clientId,
    name: name,
    phoneField: phoneField,
  );
}

Future<Client?> _saveRemoteCreate(
  WidgetRef ref,
  BuildContext context,
  AppLocalizations l10n, {
  required String name,
  String? phone,
}) async {
  if (!await guardCreateActiveProject(context, ref)) return null;

  final repo = ref.read(clientsRepositoryProvider);
  try {
    final record = await repo.createClient(name: name, phone: egyptMobileForApi(phone));
    refreshAfterClientMutation(ref, clientId: record.client.id);
    trackClientCreatedAfterApi(ref);
    return record.client;
  } on AuthApiException catch (e) {
    if (!context.mounted) return null;
    if (await handleClientsApiAuthError(context: context, ref: ref, error: e)) {
      return null;
    }
    if (!context.mounted) return null;
    if (await handleClientsApiSubscriptionError(context: context, ref: ref, error: e)) {
      return null;
    }
    if (!context.mounted) return null;
    if (e.isDuplicateName) {
      final confirm = await AppDecision.show(
        context,
        title: l10n.clientDuplicateNameTitle,
        description: l10n.clientDuplicateNameDescription,
        confirmLabel: l10n.clientDuplicateNameConfirm,
        cancelLabel: l10n.cancel,
      );
      if (confirm != OverlayAnswer.confirmed || !context.mounted) return null;
      try {
        final record = await repo.createClient(
          name: name,
          phone: egyptMobileForApi(phone),
          confirmDuplicateName: true,
        );
        refreshAfterClientMutation(ref, clientId: record.client.id);
        trackClientCreatedAfterApi(ref);
        return record.client;
      } on AuthApiException catch (retry) {
        if (!context.mounted) return null;
        if (await handleClientsApiAuthError(context: context, ref: ref, error: retry)) {
          return null;
        }
        if (!context.mounted) return null;
        if (await handleClientsApiSubscriptionError(context: context, ref: ref, error: retry)) {
          return null;
        }
        if (retry.isDuplicatePhone) {
          rethrow;
        }
        AppToaster.show(apiErrorUserMessage(l10n, retry), kind: ToastKind.failure);
      }
      return null;
    }
    if (e.isDuplicatePhone) rethrow;
    AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    return null;
  }
}

Future<Client?> _saveRemoteUpdate(
  WidgetRef ref,
  BuildContext context,
  AppLocalizations l10n, {
  required String clientId,
  required String name,
  required String phoneField,
}) async {
  final repo = ref.read(clientsRepositoryProvider);
  final normalized = egyptMobileForApi(phoneField);
  final clearPhone = normalized == null;
  try {
    final record = await repo.updateClient(
      id: clientId,
      name: name,
      phone: clearPhone ? null : normalized,
      clearPhone: clearPhone,
    );
    refreshAfterClientMutation(ref, clientId: record.client.id);
    return record.client;
  } on AuthApiException catch (e) {
    if (!context.mounted) return null;
    if (await handleClientsApiAuthError(context: context, ref: ref, error: e)) {
      return null;
    }
    if (!context.mounted) return null;
    if (e.isDuplicateName) {
      final confirm = await AppDecision.show(
        context,
        title: l10n.clientDuplicateNameTitle,
        description: l10n.clientDuplicateNameDescription,
        confirmLabel: l10n.clientDuplicateNameConfirm,
        cancelLabel: l10n.cancel,
      );
      if (confirm != OverlayAnswer.confirmed || !context.mounted) return null;
      try {
        final record = await repo.updateClient(
          id: clientId,
          name: name,
          phone: clearPhone ? null : normalized,
          clearPhone: clearPhone,
          confirmDuplicateName: true,
        );
        refreshAfterClientMutation(ref, clientId: record.client.id);
        return record.client;
      } on AuthApiException catch (retry) {
        if (!context.mounted) return null;
        if (await handleClientsApiAuthError(context: context, ref: ref, error: retry)) {
          return null;
        }
        if (retry.isDuplicatePhone) rethrow;
        AppToaster.show(apiErrorUserMessage(l10n, retry), kind: ToastKind.failure);
      }
      return null;
    }
    if (e.isDuplicatePhone) rethrow;
    AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    return null;
  }
}

String? duplicatePhoneFieldError(AppLocalizations l10n, AuthApiException error) {
  if (error.isDuplicatePhone) return l10n.clientDuplicatePhoneError;
  return null;
}

/// Confirms and deletes an online client (purge). Pops the current route on success.
Future<bool> confirmDeleteClient({
  required BuildContext context,
  required WidgetRef ref,
  required String clientId,
  required String clientName,
}) async {
  final l10n = AppLocalizations.of(context);
  final answer = await AppDecision.show(
    context,
    title: l10n.clientDeleteTitle,
    description: l10n.clientDeleteDescription(clientName),
    confirmLabel: l10n.delete,
    cancelLabel: l10n.cancel,
    tone: AppTone.danger,
  );
  if (answer != OverlayAnswer.confirmed || !context.mounted) return false;
  try {
    await ref.read(clientsRepositoryProvider).deleteClient(clientId);
    refreshAfterClientMutation(ref, clientId: clientId);
    if (context.mounted) {
      AppToaster.show(l10n.toastClientDeleted, kind: ToastKind.success);
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop();
      }
    }
    return true;
  } on AuthApiException catch (e) {
    if (!context.mounted) return false;
    if (await handleClientsApiAuthError(context: context, ref: ref, error: e)) return false;
    if (!context.mounted) return false;
    if (await handleClientsApiSubscriptionError(context: context, ref: ref, error: e)) return false;
    AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    return false;
  }
}
