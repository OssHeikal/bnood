import 'package:flutter/widgets.dart';

abstract final class AppMotion {
  static const pressScale = 0.97;
  static const pressDuration = Duration(milliseconds: 150);
  static const standard = Curves.easeInOut;
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 300);
  static const easeOut = Curves.easeOut;
  static const searchDebounce = Duration(milliseconds: 400);

  static const skeletonPulse = Duration(milliseconds: 1600);
  static const aiDotCycle = Duration(milliseconds: 1100);
  static const aiStepHold = Duration(milliseconds: 3500);
  static const aiBorderCycle = Duration(milliseconds: 5200);
  static const stateSwap = Duration(milliseconds: 250);
  static const paragraphReveal = Duration(milliseconds: 320);
  static const paragraphRevealGap = Duration(milliseconds: 90);
  static const easeOutCubic = Curves.easeOutCubic;

  static Duration durationOf(BuildContext context, Duration duration) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  }
}
