import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../core/api/api_error_user_message.dart';
import '../../core/api/auth_api_exception.dart';
import '../../core/items/item_api_record.dart';
import '../../core/items/items_error_handler.dart';
import '../../core/items/items_providers.dart';
import '../../core/shared/pagination/paging_refresh.dart';
import '../../core/widgets/app_decision.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/toast/app_tone.dart';

void refreshAfterItemMutation(WidgetRef ref) {
  bumpPagingListRefresh(ref, PagingListIds.items);
  ref.invalidate(itemIconsCatalogProvider);
  ref.invalidate(itemsCatalogByIdProvider);
}

Future<CatalogItem?> saveItemCreate({
  required WidgetRef ref,
  required BuildContext context,
  required String name,
  required String iconKey,
  required String colorKey,
}) async {
  final repo = ref.read(itemsRepositoryProvider);
  try {
    final item = await repo.createItem(name: name, iconKey: iconKey, colorKey: colorKey);
    refreshAfterItemMutation(ref);
    return item;
  } on AuthApiException catch (e) {
    if (!context.mounted) return null;
    if (await handleItemsApiAuthError(context: context, ref: ref, error: e)) {
      return null;
    }
    if (e.isDuplicateName) rethrow;
    final l10n = AppLocalizations.of(context);
    AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    return null;
  }
}

Future<CatalogItem?> saveItemUpdate({
  required WidgetRef ref,
  required BuildContext context,
  required String itemId,
  required String name,
  required String iconKey,
  required String colorKey,
}) async {
  final repo = ref.read(itemsRepositoryProvider);
  try {
    final item = await repo.updateItem(id: itemId, name: name, iconKey: iconKey, colorKey: colorKey);
    refreshAfterItemMutation(ref);
    return item;
  } on AuthApiException catch (e) {
    if (!context.mounted) return null;
    if (await handleItemsApiAuthError(context: context, ref: ref, error: e)) {
      return null;
    }
    if (e.isDuplicateName) rethrow;
    final l10n = AppLocalizations.of(context);
    if (e.isDefaultItemReadonly) {
      AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
      return null;
    }
    AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    return null;
  }
}

Future<bool> confirmDeleteItem(
  BuildContext context,
  WidgetRef ref, {
  required String itemId,
  required String name,
}) async {
  final l10n = AppLocalizations.of(context);
  final answer = await AppDecision.show(
    context,
    title: l10n.deleteItemTitle,
    description: l10n.deleteItemDescription(name),
    confirmLabel: l10n.delete,
    cancelLabel: l10n.cancel,
    tone: AppTone.danger,
    iconWidget: AppDecision.archiveDangerIcon(context),
  );
  if (answer != OverlayAnswer.confirmed) return false;
  final repo = ref.read(itemsRepositoryProvider);
  try {
    await repo.deleteItem(itemId);
    refreshAfterItemMutation(ref);
    return true;
  } on AuthApiException catch (e) {
    if (!context.mounted) return false;
    if (await handleItemsApiAuthError(context: context, ref: ref, error: e)) {
      return false;
    }
    if (e.isDefaultItemReadonly) {
      AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
      return false;
    }
    if (e.isItemInUse) {
      return _offerArchiveInUseItem(context, ref, l10n, itemId: itemId, name: name);
    }
    AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    return false;
  }
}

Future<bool> _offerArchiveInUseItem(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n, {
  required String itemId,
  required String name,
}) async {
  final archive = await AppDecision.show(
    context,
    title: l10n.itemInUseTitle,
    description: l10n.itemInUseArchiveDescription(name),
    confirmLabel: l10n.archive,
    cancelLabel: l10n.cancel,
    tone: AppTone.danger,
    iconWidget: AppDecision.archiveDangerIcon(context),
  );
  if (archive != OverlayAnswer.confirmed || !context.mounted) return false;
  return performItemArchive(context: context, ref: ref, itemId: itemId);
}

Future<bool> performItemArchive({
  required BuildContext context,
  required WidgetRef ref,
  required String itemId,
}) async {
  final l10n = AppLocalizations.of(context);
  final repo = ref.read(itemsRepositoryProvider);
  try {
    await repo.archiveItem(itemId);
    refreshAfterItemMutation(ref);
    if (context.mounted) {
      AppToaster.show(l10n.toastItemArchived, kind: ToastKind.success);
    }
    return true;
  } on AuthApiException catch (e) {
    if (!context.mounted) return false;
    if (await handleItemsApiAuthError(context: context, ref: ref, error: e)) {
      return false;
    }
    AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    return false;
  }
}

Future<bool> performItemUnarchive({
  required BuildContext context,
  required WidgetRef ref,
  required String itemId,
}) async {
  final l10n = AppLocalizations.of(context);
  final repo = ref.read(itemsRepositoryProvider);
  try {
    await repo.unarchiveItem(itemId);
    refreshAfterItemMutation(ref);
    if (context.mounted) {
      AppToaster.show(l10n.toastItemUnarchived, kind: ToastKind.success);
    }
    return true;
  } on AuthApiException catch (e) {
    if (!context.mounted) return false;
    if (await handleItemsApiAuthError(context: context, ref: ref, error: e)) {
      return false;
    }
    AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    return false;
  }
}

String? duplicateItemNameFieldError(AppLocalizations l10n, AuthApiException error) {
  if (error.isDuplicateName) return l10n.itemDuplicateNameError;
  return null;
}
