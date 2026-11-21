import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_state/settings_provider.dart';
import '../data/app_subscription.dart';
import '../data/subscription_colors.dart';
import '../data/subscription_riverpod.dart';
import '../../home/presentation/home_foundation_scope.dart';
import 'paywall_screen.dart';
import 'widgets/paywall_error_body.dart';
import 'widgets/paywall_loading_skeleton.dart';

class PaywallFlowScreen extends ConsumerStatefulWidget {
  const PaywallFlowScreen({super.key, required this.trigger});

  final PaywallFetchTrigger trigger;

  @override
  ConsumerState<PaywallFlowScreen> createState() => _PaywallFlowScreenState();
}

class _PaywallFlowScreenState extends ConsumerState<PaywallFlowScreen> {
  AsyncValue<AppPaywallContent?> _state = const AsyncLoading();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _state = const AsyncLoading());
    try {
      final languageCode = ref.read(localeProvider).languageCode;
      final snap = await ref.read(subscriptionApiProvider).getSubscription(
            languageCode: languageCode,
            paywallTrigger: widget.trigger,
          );
      if (!mounted) return;
      final paywall = snap.paywall;
      if (paywall == null || !snap.showSurfaces) {
        setState(() => _state = const AsyncData(null));
        if (mounted) Navigator.of(context).pop();
        return;
      }
      setState(() => _state = AsyncData(paywall));
    } catch (e, st) {
      if (mounted) setState(() => _state = AsyncError(e, st));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = isDark ? const Color(0xFF16121C) : SubscriptionColors.paywallCanvas;
    final gradientTop = isDark ? const Color(0xFF221833) : SubscriptionColors.paywallGradientTop;

    return HomeFoundationScope(
      child: Scaffold(
        backgroundColor: canvas,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [gradientTop, canvas],
              stops: const [0, 0.45],
            ),
          ),
          child: SafeArea(
            child: _state.when(
              loading: () => const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40),
                  Expanded(child: PaywallLoadingSkeleton()),
                ],
              ),
              error: (error, stackTrace) => PaywallErrorBody(onRetry: _load),
              data: (content) {
                if (content == null) return const SizedBox.shrink();
                if (!content.usesV3Layout || content.v3 == null) {
                  return PaywallErrorBody(onRetry: _load);
                }
                return PaywallScreen(content: content);
              },
            ),
          ),
        ),
      ),
    );
  }
}