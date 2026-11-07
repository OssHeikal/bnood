import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_decision.dart';
import '../../core/widgets/toast/app_tone.dart';

/// Returns whether the item was archived after confirmation.
Future<bool> confirmArchiveItem(
  BuildContext context,
  WidgetRef ref, {
  required String itemId,
  required String name,
}) async {
  final l10n = AppLocalizations.of(context);
  final answer = await AppDecision.show(
    context,
    title: l10n.archiveItemTitle,
    description: l10n.archiveItemDescription(name),
    confirmLabel: l10n.archive,
    cancelLabel: l10n.cancel,
    tone: AppTone.danger,
    iconWidget: AppDecision.archiveDangerIcon(context),
  );
  if (answer != OverlayAnswer.confirmed) return false;
  await ref.read(repositoryProvider).archiveItem(itemId);
  return true;
}
