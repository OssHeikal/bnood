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
///
/// Keyboard/home spacing:
/// - [BnoodModalSheet]: [OverlayFormKeyboardChrome.liftModalSheet] + [modalInnerBottomPadding]
/// - Full-screen overlays: [Scaffold.resizeToAvoidBottomInset] + [modalInnerBottomPadding] on footers
/// - Standalone footers: [sheetFooterBottomPadding] with [outerModalChromeApplied: false]
abstract final class SheetChromeInsets {
  /// Space below the last control: home indicator **or** keyboard lift, not both.
  static double sheetContentBottomPadding(
    MediaQueryData media, {
    double spacing = AppSize.spaceMD,
  }) {
    final keyboard = media.viewInsets.bottom;
    if (keyboard > 0) return keyboard + spacing;
    return media.viewPadding.bottom + spacing;
  }

  /// Inner padding for [BnoodModalSheet] after the route has already lifted for the keyboard.
  static double modalInnerBottomPadding(
    MediaQueryData media, {
    double spacing = AppSize.spaceMD,
  }) {
    if (media.viewInsets.bottom > 0) return spacing;
    return media.viewPadding.bottom + spacing;
  }

  /// Alias for tests and call sites that predate [sheetContentBottomPadding].
  static double modalBottomPadding(
    MediaQueryData media, {
    double spacing = AppSize.spaceMD,
  }) =>
      sheetContentBottomPadding(media, spacing: spacing);

  /// Footer padding when the sheet is **not** wrapped by [BnoodModalSheet] chrome.
  static double sheetFooterBottomPadding({
    required MediaQueryData media,
    required bool outerModalChromeApplied,
    double spacing = AppSize.spaceMD,
  }) {
    if (outerModalChromeApplied) return 0;
    return sheetContentBottomPadding(media, spacing: spacing);
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
