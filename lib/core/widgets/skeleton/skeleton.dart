import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../config/theme/app_motion.dart';
import '../../../l10n/app_localizations.dart';

/// Slow synchronized pulse over placeholder bones. Announces loading once.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, required this.child});

  final Widget child;

  static const double dimmest = 0.55;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: AppMotion.skeletonPulse, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still) {
      _controller.stop();
      return;
    }
    final periodMs = AppMotion.skeletonPulse.inMilliseconds;
    _controller.value = (DateTime.now().millisecondsSinceEpoch % periodMs) / periodMs;
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final label = AppLocalizations.of(context).statusLoading;
    return Semantics(
      label: label,
      container: true,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          child: widget.child,
          builder: (context, child) {
            if (still) {
              return child!;
            }
            final wave = (math.cos(_controller.value * 2 * math.pi) + 1) / 2;
            final opacity = Skeleton.dimmest + (1 - Skeleton.dimmest) * wave;
            return Opacity(opacity: opacity, child: child);
          },
        ),
      ),
    );
  }
}
