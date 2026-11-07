import 'package:flutter/material.dart';

import '../config/extensions/widget_extensions.dart';
import '../config/theme/app_motion.dart';
import '../config/theme/app_size.dart';
import '../config/theme/app_colors.dart';

class AnimatedSlideText extends StatelessWidget {
  const AnimatedSlideText({
    super.key,
    required this.isVisible,
    required this.text,
    this.textStyle,
    this.slideFromStart = true,
    this.duration = AppMotion.medium,
    this.paddingTop = AppSize.spaceXS,
    this.paddingStart = AppSize.spaceXS,
    this.showFadeAnimation = true,
  });

  final bool isVisible;
  final String? text;
  final TextStyle? textStyle;
  final bool slideFromStart;
  final Duration duration;
  final double paddingTop;
  final double paddingStart;
  final bool showFadeAnimation;

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.durationOf(context, duration);
    final visible = isVisible && text != null && text!.isNotEmpty;
    return AnimatedSize(
      duration: motion,
      curve: AppMotion.easeOut,
      alignment: Alignment.topCenter,
      child: AnimatedSlide(
        offset: _offset(context, visible),
        duration: motion,
        curve: AppMotion.standard,
        child: visible ? _label(context, motion) : const SizedBox.shrink(),
      ),
    );
  }

  Offset _offset(BuildContext context, bool visible) {
    if (visible) {
      return Offset.zero;
    }
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final fromStart = slideFromStart ? (rtl ? 1.0 : -1.0) : (rtl ? -1.0 : 1.0);
    return Offset(fromStart * 0.2, 0);
  }

  Widget _label(BuildContext context, Duration motion) {
    final child = Text(
      text!,
      style: textStyle ?? context.text.body,
    ).paddingTop(paddingTop).paddingStart(paddingStart);
    if (!showFadeAnimation) {
      return child;
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: motion,
      curve: AppMotion.easeOut,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: child,
    );
  }
}
