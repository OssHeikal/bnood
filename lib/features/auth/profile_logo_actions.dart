import 'dart:typed_data';

import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/sheet/app_sheet.dart';
import '../vouchers/voucher_receipt_picker.dart';
import 'auth_controller.dart';
import 'auth_messages.dart';
import 'profile_logo_picker.dart';
import 'profile_logo_validation.dart';

Future<void> pickAndUploadProfileLogo(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final source = await AppSheet.choices<ProfileLogoPickSource>(
    context,
    title: l10n.profileLogoPickTitle,
    choices: [
      SheetChoice(value: ProfileLogoPickSource.gallery, label: l10n.profileLogoFromGallery),
      SheetChoice(value: ProfileLogoPickSource.camera, label: l10n.profileLogoFromCamera),
    ],
  );
  if (source == null || !context.mounted) return;

  XFile? file;
  try {
    file = await ProfileLogoPicker().pick(source);
  } on VoucherReceiptPickException catch (e) {
    if (!context.mounted) return;
    AppToaster.show(voucherReceiptPickUserMessage(l10n, e), kind: ToastKind.failure);
    return;
  }
  if (file == null || !context.mounted) return;

  final bytes = await file.readAsBytes();
  if (!context.mounted) return;
  final failure = ProfileLogoValidation.validateBytes(Uint8List.fromList(bytes));
  if (failure != null) {
    AppToaster.show(_logoValidationMessage(l10n, failure), kind: ToastKind.failure);
    return;
  }

  final error = await ref
      .read(authControllerProvider.notifier)
      .uploadProfileLogo(filePath: file.path, filename: file.name);
  if (!context.mounted) return;
  if (error != null) {
    AppToaster.show(authApiMessage(l10n, error), kind: ToastKind.failure);
    return;
  }
  AppToaster.show(l10n.profileLogoUpdated, kind: ToastKind.success);
}

Future<void> showProfileLogoOptions(BuildContext context, WidgetRef ref, {required bool hasLogo}) async {
  final l10n = AppLocalizations.of(context);
  if (!hasLogo) {
    await pickAndUploadProfileLogo(context, ref);
    return;
  }
  await AppSheet.actions(
    context,
    title: l10n.profileLogo,
    actions: [
      SheetAction(label: l10n.profileLogoChange, onPressed: () => pickAndUploadProfileLogo(context, ref)),
      SheetAction(
        label: l10n.profileLogoRemove,
        destructive: true,
        destructiveTitle: l10n.profileLogoRemoveConfirmTitle,
        destructiveDescription: l10n.profileLogoRemoveConfirmBody,
        destructiveConfirmLabel: l10n.profileLogoRemove,
        onPressed: () => _deleteLogoAfterConfirm(context, ref),
      ),
    ],
  );
}

Future<void> _deleteLogoAfterConfirm(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final error = await ref.read(authControllerProvider.notifier).deleteProfileLogo();
  if (!context.mounted) return;
  if (error != null) {
    AppToaster.show(authApiMessage(l10n, error), kind: ToastKind.failure);
    return;
  }
  AppToaster.show(l10n.profileLogoRemoved, kind: ToastKind.success);
}

String _logoValidationMessage(AppLocalizations l10n, ProfileLogoValidationFailure failure) {
  return switch (failure) {
    ProfileLogoValidationFailure.tooLarge => l10n.profileLogoTooLarge,
    ProfileLogoValidationFailure.unreadable => l10n.profileLogoUnreadable,
  };
}
