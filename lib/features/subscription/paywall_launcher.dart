import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/theme/app_motion.dart';
import '../../core/subscription/app_subscription.dart';
import '../../core/subscription/subscription_riverpod.dart';
import '../home/home_foundation_scope.dart';
import 'paywall_flow_screen.dart';
import 'paywall_screen.dart';

typedef PaywallPresentFn = Future<void> Function(
  BuildContext context, {
  WidgetRef? ref,
  PaywallFetchTrigger trigger,
});

/// Override in tests to mock paywall presentation.
final paywallPresentProvider = Provider<PaywallPresentFn>((ref) => PaywallLauncher.presentDefault);

abstract final class PaywallLauncher {
  static Future<void> present(
    BuildContext context, [
    WidgetRef? ref,
    PaywallFetchTrigger trigger = PaywallFetchTrigger.defaultTrigger,
  ]) {
    final container = ref != null
        ? ProviderScope.containerOf(context, listen: false)
        : ProviderScope.containerOf(context, listen: false);
    return container.read(paywallPresentProvider)(context, ref: ref, trigger: trigger);
  }

  static Future<void> presentForContext(BuildContext context, WidgetRef ref) async {
    final ent = ref.read(subscriptionProvider).valueOrNull?.entitlements;
    final trigger = ent == null
        ? PaywallFetchTrigger.defaultTrigger
        : paywallTriggerForEntitlements(ent);
    await present(context, ref, trigger);
  }

  static Future<void> presentDefault(
    BuildContext context, {
    WidgetRef? ref,
    PaywallFetchTrigger trigger = PaywallFetchTrigger.defaultTrigger,
  }) async {
    if (!context.mounted) return;

    final container = ProviderScope.containerOf(context, listen: false);
    final snap = container.read(subscriptionProvider).valueOrNull;
    if (snap != null && !snap.showSurfaces) {
      return;
    }

    final navigator = Navigator.of(context, rootNavigator: true);
    await navigator.push<void>(
      PageRouteBuilder<void>(
        fullscreenDialog: true,
        opaque: false,
        transitionDuration: AppMotion.durationOf(context, const Duration(milliseconds: 320)),
        reverseTransitionDuration: AppMotion.durationOf(context, const Duration(milliseconds: 260)),
        pageBuilder: (context, _, _) => HomeFoundationScope(
          child: PaywallFlowScreen(trigger: trigger),
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

    // Refresh cached subscription so entitlements reflect any future checkout wiring.
    if (snap != null) {
      await container.read(subscriptionProvider.notifier).refreshSilently();
    }
  }

  /// Direct presentation when paywall content is already available (tests).
  static Future<void> presentWithContent(BuildContext context, AppPaywallContent content) async {
    if (!context.mounted) return;
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => HomeFoundationScope(child: PaywallScreen(content: content)),
      ),
    );
  }
}