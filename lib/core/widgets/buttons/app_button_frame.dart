import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../config/theme/app_size.dart';
import 'app_button_content.dart';
import 'app_button_style.dart';

/// Paints the button surface, border, shadow, focus ring, and loader.
class AppButtonFrame extends StatelessWidget {
  const AppButtonFrame({
    super.key,
    required this.colors,
    required this.radius,
    required this.borderWidth,
    required this.minHeight,
    required this.iconSize,
    required this.padding,
    required this.focused,
    required this.focusColor,
    required this.isLoading,
    required this.iconOnly,
    required this.minWidth,
    required this.hitTarget,
    required this.mixed,
    required this.centerContent,
    required this.hugWidth,
    required this.child,
  });

  final AppButtonColors colors;
  final BorderRadius radius;
  final double borderWidth;
  final double minHeight;
  final double iconSize;
  final EdgeInsets padding;
  final bool focused;
  final Color focusColor;
  final bool isLoading;
  final bool iconOnly;
  final double minWidth;
  final double hitTarget;
  final bool mixed;
  final bool centerContent;
  final bool hugWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactIcon = hugWidth && iconOnly;
        final fill =
            !hugWidth &&
            constraints.hasBoundedWidth &&
            constraints.minWidth == constraints.maxWidth &&
            constraints.maxWidth > 0;
        final visualMinWidth = fill
            ? math.max(
                minWidth,
                iconOnly
                    ? math.max(minHeight, constraints.maxWidth)
                    : constraints.maxWidth,
              )
            : math.max(minWidth, iconOnly && !compactIcon ? minHeight : 0.0);
        final tapMinWidth = math.max(
          minWidth,
          iconOnly
              ? math.max(hitTarget, compactIcon ? 0.0 : minHeight)
              : hitTarget,
        );
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: math.max(hitTarget, minHeight),
            minWidth: tapMinWidth,
          ),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: _surface(visualMinWidth, fill, compactIcon: compactIcon),
          ),
        );
      },
    );
  }

  Widget _surface(double visualMinWidth, bool fill, {required bool compactIcon}) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: radius,
            boxShadow: colors.shadow == null ? null : [colors.shadow!],
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: colors.border == null
                  ? null
                  : Border.all(
                      color: colors.border!,
                      width: borderWidth,
                    ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: compactIcon ? 0 : minHeight,
                minWidth: visualMinWidth,
              ),
              child: AppButtonSlot(
                expand: fill,
                child: Align(
                  alignment: mixed && !centerContent
                      ? AlignmentDirectional.centerStart
                      : Alignment.center,
                  widthFactor: fill ? null : 1,
                  heightFactor: 1,
                  child: Padding(padding: padding, child: _loadedChild()),
                ),
              ),
            ),
          ),
        ),
        if (focused)
          Positioned(
            left: -AppSize.focusWidth,
            top: -AppSize.focusWidth,
            right: -AppSize.focusWidth,
            bottom: -AppSize.focusWidth,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: _outset(radius),
                  border: Border.all(
                    color: focusColor,
                    width: AppSize.focusWidth,
                  ),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _loadedChild() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Visibility(
          visible: !isLoading,
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          child: child,
        ),
        if (isLoading)
          Positioned.fill(
            child: Center(
              child: ExcludeSemantics(
                child: SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSize.borderWidth,
                    color: colors.foreground,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  BorderRadius _outset(BorderRadius source) {
    Radius grow(Radius corner) {
      return Radius.elliptical(
        corner.x + AppSize.focusWidth,
        corner.y + AppSize.focusWidth,
      );
    }

    return BorderRadius.only(
      topLeft: grow(source.topLeft),
      topRight: grow(source.topRight),
      bottomLeft: grow(source.bottomLeft),
      bottomRight: grow(source.bottomRight),
    );
  }
}
