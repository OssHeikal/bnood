import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../core/api/auth_api_exception.dart';
import '../../core/clients/clients_error_handler.dart';
import '../../core/clients/clients_providers.dart';
import '../../core/database/database.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/dashboard_providers.dart';
import '../../core/widgets/app_decision.dart';
import '../../core/widgets/app_toaster.dart';
import '../subscription/subscription_error_handler.dart';
import '../subscription/subscription_gates.dart';

Future<Client?> saveClientCreate({
  required WidgetRef ref,
  required BuildContext context,
  required String name,
  String? phone,
}) async {
  final l10n = AppLocalizations.of(context);
  if (ref.read(remoteClientsEnabledProvider)) {
    return _saveRemoteCreate(ref, context, l10n, name: name, phone: phone);
  }
  return ref.read(repositoryProvider).createClient(name: name, phone: phone);
}

Future<Client?> saveClientUpdate({
  required WidgetRef ref,
  required BuildContext context,
  required String clientId,
  required String name,
  required String phoneField,
}) async {
  final l10n = AppLocalizations.of(context);
  if (ref.read(remoteClientsEnabledProvider)) {
    return _saveRemoteUpdate(
      ref,
      context,
      l10n,
      clientId: clientId,
      name: name,
      phoneField: phoneField,
    );
  }
  return ref.read(repositoryProvider).updateClient(
        clientId: clientId,
        name: name,
        phone: phoneField.trim().isEmpty ? '' : phoneField.trim(),
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
    final record = await repo.createClient(name: name, phone: phone);
    refreshAfterClientMutation(ref, clientId: record.client.id);
    return record.client;
  } on AuthApiException catch (e) {
    if (!context.mounted) return null;
    if (await handleClientsApiAuthError(context: context, ref: ref, error: e)) {
      return null;
    }
    if (await handleClientsApiSubscriptionError(context: context, ref: ref, error: e)) {
      return null;
    }
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
          phone: phone,
          confirmDuplicateName: true,
        );
        refreshAfterClientMutation(ref, clientId: record.client.id);
        return record.client;
      } on AuthApiException catch (retry) {
        if (!context.mounted) return null;
        if (await handleClientsApiAuthError(context: context, ref: ref, error: retry)) {
          return null;
        }
        if (await handleClientsApiSubscriptionError(context: context, ref: ref, error: retry)) {
          return null;
        }
        if (retry.isDuplicatePhone) {
          throw retry;
        }
        AppToaster.show(retry.message, kind: ToastKind.failure);
      }
      return null;
    }
    if (e.isDuplicatePhone) rethrow;
    AppToaster.show(e.message, kind: ToastKind.failure);
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
  final trimmedPhone = phoneField.trim();
  final clearPhone = trimmedPhone.isEmpty;
  try {
    final record = await repo.updateClient(
      id: clientId,
      name: name,
      phone: clearPhone ? null : trimmedPhone,
      clearPhone: clearPhone,
    );
    refreshAfterClientMutation(ref, clientId: record.client.id);
    return record.client;
  } on AuthApiException catch (e) {
    if (!context.mounted) return null;
    if (await handleClientsApiAuthError(context: context, ref: ref, error: e)) {
      return null;
    }
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
          phone: clearPhone ? null : trimmedPhone,
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
        AppToaster.show(retry.message, kind: ToastKind.failure);
      }
      return null;
    }
    if (e.isDuplicatePhone) rethrow;
    AppToaster.show(e.message, kind: ToastKind.failure);
    return null;
  }
}

String? duplicatePhoneFieldError(AppLocalizations l10n, AuthApiException error) {
  if (error.isDuplicatePhone) return l10n.clientDuplicatePhoneError;
  return null;
}
