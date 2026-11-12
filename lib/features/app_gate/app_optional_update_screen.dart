import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../core/app_gate/app_config_record.dart';
import '../../core/utils/safe_external_url.dart';
import 'app_gate_cold_start.dart';
import 'app_gate_provider.dart';
import 'app_gate_session.dart';
import 'widgets/gate_blocking_scaffold.dart';

class AppOptionalUpdateScreen extends ConsumerWidget {
  const AppOptionalUpdateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(appGateProvider).valueOrNull ?? AppConfigData.failOpen();
    final message = config.messageForDisplay(
      () => l10n.gateMaintenanceFallbackMessage,
      () => l10n.gateForceUpdateFallbackMessage,
      () => l10n.gateOptionalUpdateFallbackMessage,
    );
    return GateBlockingScaffold(
      title: l10n.gateOptionalUpdateTitle,
      message: message,
      primaryLabel: l10n.gateUpdateAction,
      secondaryLabel: l10n.gateLaterAction,
      onPrimary: () => openStoreUrl(config.storeUrl),
      onSecondary: () {
        AppGateColdStart.optionalDismissed = true;
        final dest = AppGateSession.postSplashDestination ?? '/auth/login';
        context.go(dest);
      },
    );
  }
}
