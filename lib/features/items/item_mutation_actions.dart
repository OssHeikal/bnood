import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bnood/l10n/app_localizations.dart';

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
    AppToaster.show(e.message, kind: ToastKind.failure);
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
    if (e.isDefaultItemReadonly) {
      AppToaster.show(e.message, kind: ToastKind.failure);
      return null;
    }
    AppToaster.show(e.message, kind: ToastKind.failure);
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
    AppToaster.show(e.message, kind: ToastKind.failure);
    return false;
  }
}

String? duplicateItemNameFieldError(AppLocalizations l10n, AuthApiException error) {
  if (error.isDuplicateName) return l10n.itemDuplicateNameError;
  return null;
}
