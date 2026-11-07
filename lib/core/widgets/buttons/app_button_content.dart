import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../config/theme/app_size.dart';
import 'app_button_type.dart';

/// Tells the label row whether the button is filling its width.
class AppButtonSlot extends InheritedWidget {
  const AppButtonSlot({super.key, required this.expand, required super.child});

  final bool expand;

  static bool expandOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppButtonSlot>()?.expand ?? false;
  }

  @override
  bool updateShouldNotify(AppButtonSlot oldWidget) => expand != oldWidget.expand;
}

/// Lays out a button label with optional icons and a badge, on one line.
///
/// A single label stays as the label. A row that also has an icon or a badge
/// keeps a fixed leading slot and a trailing cluster, and centers that row
/// in [barHeight].
class AppButtonContent extends StatelessWidget {
  const AppButtonContent({
    super.key,
    required this.gap,
    required this.iconSize,
    required this.barHeight,
    this.label,
    this.leading,
    this.trailing,
    this.badge,
    this.stacked = false,
    this.align = AppButtonContentAlign.spaceBetween,
  });

  final Widget? label;
  final Widget? leading;
  final Widget? trailing;
  final Widget? badge;
  final double gap;
  final double iconSize;
  final double barHeight;
  final bool stacked;
  final AppButtonContentAlign align;

  bool get _mixed => !stacked && label != null && (leading != null || trailing != null || badge != null);

  @override
  Widget build(BuildContext context) {
    if (stacked) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?leading,
          if (leading != null && label != null) SizedBox(height: gap),
          ?label,
        ],
      );
    }
    if (!_mixed) {
      return _capped(label);
    }
    return SizedBox(
      height: barHeight,
      child: Builder(
        builder: (context) {
          if (AppButtonSlot.expandOf(context) && align == AppButtonContentAlign.spaceBetween) {
            return _pinned();
          }
          return _grouped();
        },
      ),
    );
  }

  Widget _pinned() {
    return Row(
      children: [
        if (leading != null) _slot(leading!),
        if (leading != null) SizedBox(width: gap),
        Expanded(
          child: Align(alignment: AlignmentDirectional.centerStart, child: label),
        ),
        ?_cluster(gapBefore: true),
      ],
    );
  }

  Widget _grouped() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final text = _limited(label, _textMax(constraints));
        final leadingBalance = _opticalBalance(oppositeTrailing: false);
        final trailingBalance = _opticalBalance(oppositeTrailing: true);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingBalance > 0) SizedBox(width: leadingBalance),
            if (leading != null) _slot(leading!),
            if (leading != null && text != null) SizedBox(width: gap),
            ?text,
            ?_cluster(gapBefore: text != null || leading != null),
            if (trailingBalance > 0) SizedBox(width: trailingBalance),
          ],
        );
      },
    );
  }

  Widget _slot(Widget icon) {
    return SizedBox(
      width: iconSize,
      child: Align(alignment: Alignment.center, child: icon),
    );
  }

  Widget? _cluster({required bool gapBefore}) {
    if (badge == null && trailing == null) {
      return null;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (gapBefore) SizedBox(width: gap),
        ?badge,
        if (badge != null && trailing != null) SizedBox(width: gap),
        ?trailing,
      ],
    );
  }

  Widget _capped(Widget? child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (child == null || !constraints.maxWidth.isFinite) {
          return child ?? const SizedBox.shrink();
        }
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
          child: child,
        );
      },
    );
  }

  double? _textMax(BoxConstraints constraints) {
    if (!constraints.maxWidth.isFinite) {
      return null;
    }
    return math.max(0.0, constraints.maxWidth - _reserved());
  }

  /// The gap between the label and the icon, placed on the empty side.
  double _opticalBalance({required bool oppositeTrailing}) {
    if (align != AppButtonContentAlign.center || label == null) {
      return 0;
    }
    final hasLeading = leading != null;
    final hasTrailing = trailing != null || badge != null;
    if (oppositeTrailing) {
      return hasLeading && !hasTrailing ? gap : 0;
    }
    return !hasLeading && hasTrailing ? gap : 0;
  }

  double _reserved() {
    var reserved = _opticalBalance(oppositeTrailing: false);
    reserved += _opticalBalance(oppositeTrailing: true);
    if (leading != null) {
      reserved += iconSize + gap;
    }
    if (trailing != null) {
      reserved += iconSize;
    }
    if (badge != null) {
      reserved += iconSize;
    }
    if (trailing != null && badge != null) {
      reserved += gap;
    }
    if (trailing != null || badge != null) {
      reserved += gap;
    }
    return reserved;
  }

  Widget? _limited(Widget? child, double? maxWidth) {
    if (child == null || maxWidth == null) {
      return child;
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );
  }
}

/// Shaves [AppSize.spaceXS] off the icon side when a label has one icon.
/// Start and end follow [direction].
EdgeInsets opticalButtonPadding({
  required EdgeInsetsDirectional padding,
  required bool hasLabel,
  required bool hasLeading,
  required bool hasTrailing,
  required TextDirection direction,
}) {
  final oneIcon = hasLabel && (hasLeading != hasTrailing);
  if (!oneIcon) {
    return padding.resolve(direction);
  }
  return EdgeInsetsDirectional.fromSTEB(
    hasLeading ? padding.start - AppSize.spaceXS : padding.start,
    padding.top,
    hasTrailing ? padding.end - AppSize.spaceXS : padding.end,
    padding.bottom,
  ).resolve(direction);
}
