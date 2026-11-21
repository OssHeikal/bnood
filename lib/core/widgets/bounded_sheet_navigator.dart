import 'package:flutter/material.dart';

import 'sheet_keyboard_back_scope.dart';

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
        pageBuilder: (ctx, animation, secondaryAnimation) =>
            SheetKeyboardBackScope(child: builder(ctx)),
      ),
    );
  }
}

/// Content max-height for modal sheets ([AppModalSheet]).
abstract final class SheetContentBounds {
  static const viewportFraction = 0.9;

  static double viewportCap(MediaQueryData media) {
    final available = media.size.height - media.viewInsets.bottom - media.viewPadding.top;
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