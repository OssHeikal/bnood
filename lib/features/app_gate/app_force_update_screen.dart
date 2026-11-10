import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../core/app_gate/app_config_record.dart';
import '../../core/utils/safe_external_url.dart';
import 'app_gate_provider.dart';
import 'widgets/gate_blocking_scaffold.dart';

class AppForceUpdateScreen extends ConsumerWidget {
  const AppForceUpdateScreen({super.key});

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
      title: l10n.gateForceUpdateTitle,
      message: message,
      primaryLabel: l10n.gateUpdateAction,
      onPrimary: () => openStoreUrl(config.storeUrl),
    );
  }
}
