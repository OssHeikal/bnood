import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/theme/app_motion.dart';
import '../../core/subscription/subscription_riverpod.dart';
import '../home/home_foundation_scope.dart';
import 'paywall_screen.dart';

typedef PaywallPresentFn = Future<void> Function(BuildContext context, [WidgetRef? ref]);

/// Override in tests to mock paywall presentation.
final paywallPresentProvider = Provider<PaywallPresentFn>((ref) => PaywallLauncher.presentDefault);

abstract final class PaywallLauncher {
  static Future<void> present(BuildContext context, [WidgetRef? ref]) {
    return ProviderScope.containerOf(context, listen: false).read(paywallPresentProvider)(context, ref);
  }

  static Future<void> presentDefault(BuildContext context, [WidgetRef? ref]) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final snap = container.read(subscriptionProvider).valueOrNull;
    if (snap == null || !snap.showSurfaces || snap.paywall == null) return;
    if (!context.mounted) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    await navigator.push<void>(
      PageRouteBuilder<void>(
        fullscreenDialog: true,
        opaque: false,
        transitionDuration: AppMotion.durationOf(context, const Duration(milliseconds: 320)),
        reverseTransitionDuration: AppMotion.durationOf(context, const Duration(milliseconds: 260)),
        pageBuilder: (context, _, _) => HomeFoundationScope(
          child: PaywallScreen(content: snap.paywall!),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (MediaQuery.disableAnimationsOf(context)) return child;
          final curved = CurvedAnimation(
            parent: animation,
            curve: AppMotion.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
            child: child,
          );
        },
      ),
    );
  }
}
