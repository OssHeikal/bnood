import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_gate/app_config_record.dart';
import '../features/app_gate/app_gate_paths.dart';
import '../features/app_gate/app_gate_provider.dart';

/// Refetch app config on resume; only maintenance / force-update replace the route.
class AppGateLifecycle extends ConsumerStatefulWidget {
  const AppGateLifecycle({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppGateLifecycle> createState() => _AppGateLifecycleState();
}

class _AppGateLifecycleState extends ConsumerState<AppGateLifecycle> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _onResume();
  }

  Future<void> _onResume() async {
    final config = await ref.read(appGateProvider.notifier).fetchConfig(failOpen: true);
    if (!mounted) return;
    if (config.status != AppGateStatus.maintenance && config.status != AppGateStatus.forceUpdate) {
      return;
    }
    final router = GoRouter.of(context);
    final loc = router.state.matchedLocation;
    if (isAppGateLocation(loc)) return;
    final target = switch (config.status) {
      AppGateStatus.maintenance => AppGatePaths.maintenance,
      AppGateStatus.forceUpdate => AppGatePaths.forceUpdate,
      _ => null,
    };
    if (target != null) {
      router.go(target);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
