import 'package:flutter/material.dart';

import '../layout/bnood_layout.dart';
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
      useSafeArea: false,
      backgroundColor: backgroundColor ?? colors.surface,
      shape: shape ?? AppShape.superellipse(radius: AppSize.radiusLG),
      builder: (ctx) {
        final media = MediaQuery.of(ctx);
        final bottomPad = SheetChromeInsets.modalBottomPadding(media);
        Widget sheet = SafeArea(
          top: true,
          left: true,
          right: true,
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPad),
            child: frame(context: ctx, child: Builder(builder: builder)),
          ),
        );
        if (!ctx.isBnoodMobile) {
          sheet = Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ctx.formMaxWidth),
              child: sheet,
            ),
          );
        }
        return sheet;
      },
    );
  }

  /// Caps height at 80% viewport; child defines intrinsic height (short sheets hug content).
  static Widget frame({required BuildContext context, required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cap = SheetContentBounds.viewportCap(MediaQuery.of(context));
        final maxW = context.isBnoodMobile ? constraints.maxWidth : context.formMaxWidth;
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxW,
            maxHeight: cap,
          ),
          child: child,
        );
      },
    );
  }
}
