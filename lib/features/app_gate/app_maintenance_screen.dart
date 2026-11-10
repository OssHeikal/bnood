import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../core/app_gate/app_config_record.dart';
import 'app_gate_provider.dart';
import 'app_gate_session.dart';
import 'widgets/gate_blocking_scaffold.dart';

class AppMaintenanceScreen extends ConsumerStatefulWidget {
  const AppMaintenanceScreen({super.key});

  @override
  ConsumerState<AppMaintenanceScreen> createState() => _AppMaintenanceScreenState();
}

class _AppMaintenanceScreenState extends ConsumerState<AppMaintenanceScreen> {
  var _retrying = false;

  Future<void> _retry() async {
    if (_retrying) return;
    setState(() => _retrying = true);
    try {
      final config = await ref.read(appGateProvider.notifier).fetchConfig(failOpen: false);
      if (!mounted) return;
      if (config.status != AppGateStatus.maintenance) {
        final dest = AppGateSession.postSplashDestination ?? '/auth/login';
        context.go(dest);
      }
    } catch (_) {
      // Stay on maintenance.
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(appGateProvider).valueOrNull ?? AppConfigData.failOpen();
    final message = config.messageForDisplay(
      () => l10n.gateMaintenanceFallbackMessage,
      () => l10n.gateForceUpdateFallbackMessage,
      () => l10n.gateOptionalUpdateFallbackMessage,
    );
    return GateBlockingScaffold(
      title: l10n.gateMaintenanceTitle,
      message: message,
      primaryLabel: l10n.retry,
      primaryLoading: _retrying,
      onPrimary: _retry,
    );
  }
}
