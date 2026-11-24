import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_state/settings_provider.dart';
import '../core/data/prefs/app_settings_store.dart';
import '../core/network/push/push_platform.dart';
import '../core/services/analytics/appsflyer/appsflyer_bootstrap.dart';
import '../core/services/analytics/providers/analytics_providers.dart';
import '../core/services/error_reporting/error_reporting_providers.dart';
import '../core/services/error_reporting/install_error_handlers.dart';
import 'app_root_restart.dart';
import 'app_splash_session.dart';
import 'bnood_app.dart';

/// Hosts [ProviderContainer] and recreates it on ledger account switch.
class BnoodRoot extends StatefulWidget {
  const BnoodRoot({super.key, required this.bootstrap});

  final AppSettingsSnapshot bootstrap;

  @override
  State<BnoodRoot> createState() => _BnoodRootState();
}

class _BnoodRootState extends State<BnoodRoot> {
  late ProviderContainer _container;
  var _generation = 0;

  @override
  void initState() {
    super.initState();
    _container = _newContainer(widget.bootstrap);
    AppRootRestart.bind(_restartLedgerScope);
  }

  @override
  void dispose() {
    AppRootRestart.unbind();
    _container.dispose();
    super.dispose();
  }

  ProviderContainer _newContainer(AppSettingsSnapshot bootstrap) {
    final container = ProviderContainer(
      overrides: [appSettingsBootstrapProvider.overrideWithValue(bootstrap)],
    );
    installErrorHandlers(container.read(errorReporterProvider));
    if (pushMessagingSupported) {
      AppsFlyerBootstrap.onSessionStarted = () {
        container.invalidate(appsFlyerGatewayProvider);
        container.invalidate(analyticsSinksProvider);
        container.invalidate(analyticsServiceProvider);
      };
    }
    return container;
  }

  void _restartLedgerScope() {
    if (!mounted) return;
    final bootstrap = _container.read(appSettingsBootstrapProvider);
    _container.dispose();
    AppSplashSession.restartForAccountSwitch();
    _container = _newContainer(bootstrap);
    setState(() => _generation++);
  }

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      key: ValueKey('bnood-scope-$_generation'),
      container: _container,
      child: const BnoodApp(),
    );
  }
}