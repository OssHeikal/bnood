import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_decision.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/toast/app_tone.dart';
import 'auth_controller.dart';
import 'auth_messages.dart';
import 'auth_paths.dart';

Future<void> confirmLogout(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final answer = await AppDecision.show(
    context,
    title: l10n.authLogoutConfirmTitle,
    description: l10n.authLogoutConfirmBody,
    confirmLabel: l10n.authSignOut,
    cancelLabel: l10n.cancel,
    tone: AppTone.danger,
    icon: Icons.logout,
  );
  if (answer != OverlayAnswer.confirmed || !context.mounted) return;
  final failure = await ref.read(authControllerProvider.notifier).logout();
  if (!context.mounted) return;
  if (failure != null) {
    AppToaster.show(authApiMessage(l10n, failure), kind: ToastKind.warning);
  }
  context.go(AuthPaths.login);
}
