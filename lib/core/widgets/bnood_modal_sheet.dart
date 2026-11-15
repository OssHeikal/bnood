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
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    final brightness = Theme.of(context).brightness;
    final colors = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      showDragHandle: false,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      builder: (ctx) {
        final media = MediaQuery.of(ctx);
        final viewPad = media.viewPadding;
        final cap = SheetContentBounds.viewportCap(media);
        final isMobile = ctx.isBnoodMobile;
        final maxWidth = isMobile ? media.size.width : ctx.formMaxWidth;
        final innerBottom = SheetChromeInsets.modalInnerBottomPadding(media);

        Widget child = Builder(builder: builder);

        Widget body = fitContent
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: SingleChildScrollView(
                      primary: false,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      child: child,
                    ),
                  ),
                ],
              )
            : frame(context: ctx, child: child);

        if (isMobile) {
          body = Padding(
            padding: EdgeInsets.only(bottom: innerBottom),
            child: body,
          );
        }

        final defaultShape = isMobile
            ? AppShape.sheetMobileTop(radius: AppSize.radiusLG)
            : AppShape.superellipse(radius: AppSize.radiusLG);

        Widget sheet = Material(
          color: backgroundColor ?? colors.surface,
          shape: shape ?? defaultShape,
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            key: sheetBoundsKey,
            constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: cap),
            child: body,
          ),
        );

        if (isMobile) {
          sheet = Padding(
            padding: EdgeInsets.only(
              top: viewPad.top,
              left: viewPad.left,
              right: viewPad.right,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              widthFactor: 1,
              child: sheet,
            ),
          );
          final keyboardLift = media.viewInsets.bottom;
          if (keyboardLift > 0) {
            sheet = Padding(
              padding: EdgeInsets.only(bottom: keyboardLift),
              child: sheet,
            );
          }
        } else {
          sheet = Padding(
            padding: EdgeInsets.fromLTRB(
              viewPad.left,
              viewPad.top,
              viewPad.right,
              innerBottom,
            ),
            child: Align(alignment: Alignment.bottomCenter, child: sheet),
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