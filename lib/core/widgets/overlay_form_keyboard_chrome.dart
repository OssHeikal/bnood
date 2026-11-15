import 'package:flutter/material.dart';

import 'bounded_sheet_navigator.dart';

/// Single keyboard-inset rules for modal sheets, in-sheet overlays, and
/// full-screen picker/create routes.
abstract final class OverlayFormKeyboardChrome {
  /// Lifts [child] above the keyboard on phone modals ([BnoodModalSheet]).
  /// Call once at the sheet shell; do not also pad footers with [viewInsets.bottom].
  static Widget liftModalSheet({
    required MediaQueryData media,
    required bool enabled,
    required Widget child,
  }) {
    if (!enabled) return child;
    final lift = media.viewInsets.bottom;
    if (lift <= 0) return child;
    return Padding(
      padding: EdgeInsets.only(bottom: lift),
      child: child,
    );
  }

  /// Footer spacing when modal lift or [Scaffold.resizeToAvoidBottomInset] already applied.
  static double pinnedFooterBottom(MediaQueryData media) =>
      SheetChromeInsets.modalInnerBottomPadding(media);
}