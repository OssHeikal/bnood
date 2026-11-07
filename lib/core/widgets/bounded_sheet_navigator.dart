import 'package:flutter/material.dart';

import '../config/theme/app_size.dart';

/// Nested [Navigator] with a finite max height for content-sized modal sheets.
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final maxHeight = SheetContentBounds.maxHeight(constraints, media);
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth,
            maxHeight: maxHeight,
          ),
          child: Navigator(
            key: navigatorKey,
            onGenerateRoute: (settings) => MaterialPageRoute(builder: builder, settings: settings),
          ),
        );
      },
    );
  }

}

/// Shared max-height policy for modal sheet bodies (nested navigator + inline create).
abstract final class SheetContentBounds {
  static double maxHeight(BoxConstraints constraints, MediaQueryData media) {
    final bottomInset = media.viewInsets.bottom;
    final parent = constraints.maxHeight;
    if (parent.isFinite && parent > 0) {
      return parent;
    }
    final reservedTop = media.viewPadding.top + AppSize.space2XL;
    final viewportCap = media.size.height - reservedTop - bottomInset;
    return viewportCap.clamp(0, double.infinity);
  }
}
