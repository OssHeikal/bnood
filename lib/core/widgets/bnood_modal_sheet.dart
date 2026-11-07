import 'package:flutter/material.dart';

import '../config/theme/app_colors.dart';
import '../config/theme/app_shape.dart';
import '../config/theme/app_size.dart';
import 'bounded_sheet_navigator.dart';

/// Shared Bnood modal bottom sheet: content-sized up to [SheetContentBounds.viewportCap].
abstract final class BnoodModalSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool useRootNavigator = true,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) {
    final brightness = Theme.of(context).brightness;
    final colors = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      isScrollControlled: true,
      showDragHandle: false,
      useSafeArea: true,
      backgroundColor: backgroundColor ?? colors.surface,
      shape: shape ?? AppShape.superellipse(radius: AppSize.radiusLG),
      builder: (ctx) {
        final insets = MediaQuery.viewInsetsOf(ctx);
        final keyboardGap = insets.bottom > 0 ? AppSize.spaceMD : 0.0;
        return Padding(
          padding: EdgeInsets.only(bottom: insets.bottom > 0 ? insets.bottom + keyboardGap : 0),
          child: frame(child: Builder(builder: builder)),
        );
      },
    );
  }

  /// Caps height at 80% viewport; child defines intrinsic height (short sheets hug content).
  static Widget frame({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cap = SheetContentBounds.viewportCap(MediaQuery.of(context));
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth,
            maxHeight: cap,
          ),
          child: child,
        );
      },
    );
  }
}
