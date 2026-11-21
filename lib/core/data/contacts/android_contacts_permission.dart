import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../l10n/app_localizations.dart';
import '../../ui/widgets/app_decision.dart';
import '../../ui/widgets/app_toaster.dart';
import '../../ui/widgets/toast/app_tone.dart';

/// Android runtime [Permission.contacts] before native contact import.
Future<bool> ensureAndroidContactsPermission(BuildContext context) async {
  if (!Platform.isAndroid) return true;
  final l10n = AppLocalizations.of(context);
  var status = await Permission.contacts.status;
  if (status.isGranted) return true;
  if (status.isDenied) {
    status = await Permission.contacts.request();
    if (status.isGranted) return true;
    if (!context.mounted) return false;
    if (status.isPermanentlyDenied) {
      return _openSettingsPrompt(context, l10n);
    }
    AppToaster.warning(l10n.contactsPermissionDeniedBody);
    return false;
  }
  if (status.isPermanentlyDenied) {
    if (!context.mounted) return false;
    return _openSettingsPrompt(context, l10n);
  }
  if (status.isRestricted) {
    if (!context.mounted) return false;
    AppToaster.warning(l10n.contactsPermissionRestrictedBody);
    return false;
  }
  return false;
}

Future<bool> _openSettingsPrompt(
  BuildContext context,
  AppLocalizations l10n,
) async {
  final answer = await AppDecision.show(
    context,
    title: l10n.contactsPermissionSettingsTitle,
    description: l10n.contactsPermissionSettingsBody,
    confirmLabel: l10n.contactsPermissionOpenSettings,
    cancelLabel: l10n.cancel,
    tone: AppTone.warning,
  );
  if (answer == OverlayAnswer.confirmed) {
    await openAppSettings();
  }
  return false;
}
