import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/subscription/subscription_riverpod.dart';
import '../home/home_foundation_scope.dart';
import 'paywall_screen.dart';

abstract final class PaywallLauncher {
  static Future<void> present(BuildContext context, [WidgetRef? ref]) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final snap = container.read(subscriptionProvider).valueOrNull;
    if (snap == null || !snap.showSurfaces || snap.paywall == null) return;
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        fullscreenDialog: true,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, _, _) => HomeFoundationScope(
              child: PaywallScreen(content: snap.paywall!),
            ),
      ),
    );
  }
}
