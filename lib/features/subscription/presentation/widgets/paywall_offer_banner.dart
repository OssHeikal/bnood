import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/formatting/display_digits.dart';
import 'package:bnood/features/subscription/data/paywall_v3_models.dart';
import 'package:bnood/features/subscription/data/subscription_colors.dart';
import 'package:bnood/features/subscription/presentation/widgets/paywall_theme.dart';

class PaywallOfferBanner extends StatefulWidget {
  const PaywallOfferBanner({super.key, required this.banner});

  final AppPaywallOfferBanner banner;

  @override
  State<PaywallOfferBanner> createState() => _PaywallOfferBannerState();
}

class _PaywallOfferBannerState extends State<PaywallOfferBanner> {
  Timer? _timer;
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    _tick();
    if (widget.banner.showCountdown && widget.banner.endsAt != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  void _tick() {
    final ends = widget.banner.endsAt;
    if (ends == null) return;
    final now = DateTime.now();
    if (!mounted) return;
    setState(() {
      _remaining = ends.isAfter(now) ? ends.difference(now) : Duration.zero;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String? _countdownLabel() {
    final remaining = _remaining;
    if (remaining == null) return null;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);
    final text =
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
    return DisplayDigits.toWesternDigits(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = PaywallTheme.of(context);
    final countdown = widget.banner.showCountdown ? _countdownLabel() : null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SubscriptionColors.violetDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.banner.text,
                style: theme.offerBanner,
                textAlign: TextAlign.start,
              ),
            ),
            if (countdown != null) ...[
              const SizedBox(width: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Text(
                    countdown,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      fontFeatures: [FontFeature.tabularFigures()],
                      letterSpacing: 0.04 * 12,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
