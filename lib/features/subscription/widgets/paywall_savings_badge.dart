import 'package:flutter/material.dart';

import '../../../core/subscription/subscription_colors.dart';

class PaywallSavingsBadge extends StatefulWidget {
  const PaywallSavingsBadge({super.key, required this.label, required this.visible});

  final String label;
  final bool visible;

  @override
  State<PaywallSavingsBadge> createState() => _PaywallSavingsBadgeState();
}

class _PaywallSavingsBadgeState extends State<PaywallSavingsBadge> with SingleTickerProviderStateMixin {
  /// 5.6s cycle: ~1.6s hold, ~1.4s sweep, ~2.6s rest.
  static const _lead = 0.28;
  static const _sweepEnd = 0.54;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 5600))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible || widget.label.isEmpty) return const SizedBox.shrink();

    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return PositionedDirectional(
      top: 0,
      end: 0,
      child: ClipRRect(
        borderRadius: const BorderRadiusDirectional.only(
          topEnd: Radius.circular(20),
          bottomStart: Radius.circular(14),
        ),
        child: Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: SubscriptionColors.violet,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 16, 9),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    shadows: [Shadow(color: Color(0x59280A50), offset: Offset(0, 1), blurRadius: 1)],
                  ),
                ),
              ),
            ),
            if (!reduceMotion)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final t = _controller.value;
                    final start = t < _lead || t > _sweepEnd
                        ? (t > _sweepEnd ? 1.35 : -1.35)
                        : -1.25 + ((t - _lead) / (_sweepEnd - _lead)) * 2.6;
                    return FractionalTranslation(
                      translation: Offset(start, 0),
                      child: Transform(
                        transform: Matrix4.skewX(-0.38),
                        child: Container(
                          width: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: 0.15),
                                Colors.white.withValues(alpha: 0.7),
                                Colors.white.withValues(alpha: 0.15),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
