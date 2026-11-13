import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/theme/app_size.dart';

/// Nested [Navigator] for in-sheet flows (inline create, roster amount, etc.).
class BoundedSheetNavigator extends StatelessWidget {
  const BoundedSheetNavigator({
    super.key,
    required this.builder,
    this.navigatorKey,
  });

  final WidgetBuilder builder;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) => PageRouteBuilder<void>(
        settings: settings,
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (ctx, animation, secondaryAnimation) => builder(ctx),
      ),
    );
  }
}

/// Viewport cap (80% of screen) and content max-height helpers for modal sheets.
/// Home indicator, keyboard lift, and content spacing for modal sheets.
abstract final class SheetChromeInsets {
  /// Bottom inset for [BnoodModalSheet] chrome: `max(home, keyboard) + [spacing]`.
  static double modalBottomPadding(
    MediaQueryData media, {
    double spacing = AppSize.spaceMD,
  }) {
    return math.max(media.viewPadding.bottom, media.viewInsets.bottom) + spacing;
  }

  /// Footer padding inside a sheet when outer modal chrome already applied.
  static double sheetFooterBottomPadding({
    required MediaQueryData media,
    required bool outerModalChromeApplied,
    double spacing = AppSize.spaceMD,
  }) {
    if (outerModalChromeApplied) return spacing;
    return math.max(media.viewPadding.bottom, media.viewInsets.bottom) + spacing;
  }
}

abstract final class SheetContentBounds {
  static const viewportFraction = 0.8;

  /// Maximum sheet body height for the current viewport (keyboard subtracted).
  static double viewportCap(MediaQueryData media) {
    final available = media.size.height - media.viewInsets.bottom;
    return (available * viewportFraction).clamp(0, double.infinity);
  }

  static double maxHeight(BoxConstraints constraints, MediaQueryData media) {
    final cap = viewportCap(media);
    final parent = constraints.maxHeight;
    if (parent.isFinite && parent > 0) {
      return parent < cap ? parent : cap;
    }
    return cap;
  }
}
