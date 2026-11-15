import 'package:flutter/material.dart';

import '../layout/bnood_layout.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_shape.dart';
import '../config/theme/app_size.dart';
import 'bounded_sheet_navigator.dart';

/// Shared Bnood modal bottom sheet: content-sized up to [SheetContentBounds.viewportCap].
abstract final class BnoodModalSheet {
  static const sheetBoundsKey = Key('bnood_modal_sheet_bounds');

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool useRootNavigator = true,
    Color? backgroundColor,
    ShapeBorder? shape,
    bool fitContent = true,
  }) {
    final brightness = Theme.of(context).brightness;
    final colors = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      isScrollControlled: true,
      showDragHandle: false,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      builder: (ctx) {
        final media = MediaQuery.of(ctx);
        final bottomPad = SheetChromeInsets.modalBottomPadding(media);
        final viewPad = media.viewPadding;
        final cap = SheetContentBounds.viewportCap(media);
        final maxWidth = ctx.isBnoodMobile ? media.size.width : ctx.formMaxWidth;

        Widget body = fitContent
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [Builder(builder: builder)],
              )
            : frame(context: ctx, child: Builder(builder: builder));

        Widget sheet = Material(
          color: backgroundColor ?? colors.surface,
          shape: shape ?? AppShape.superellipse(radius: AppSize.radiusLG),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            key: sheetBoundsKey,
            constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: cap),
            child: body,
          ),
        );

        sheet = Padding(
          padding: EdgeInsets.only(
            top: viewPad.top,
            left: viewPad.left,
            right: viewPad.right,
            bottom: bottomPad,
          ),
          child: sheet,
        );

        if (!ctx.isBnoodMobile) {
          sheet = Align(alignment: Alignment.bottomCenter, child: sheet);
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
