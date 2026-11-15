import 'package:flutter/material.dart';

import 'overlay_form_keyboard_chrome.dart';

/// Full-screen overlay routes pushed on the root navigator (pickers, inline
/// create, voucher). Pair with [Scaffold.resizeToAvoidBottomInset] and
/// [OverlayFormKeyboardChrome.pinnedFooterBottom] — do not zero [viewInsets].
class FullScreenOverlayKeyboardScope extends StatelessWidget {
  const FullScreenOverlayKeyboardScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;

  static double pinnedFooterBottomPadding(MediaQueryData media) =>
      OverlayFormKeyboardChrome.pinnedFooterBottom(media);
}