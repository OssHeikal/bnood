import 'package:flutter/material.dart';

import '../config/theme/app_size.dart';

/// Full-screen overlay routes: [Scaffold.resizeToAvoidBottomInset] lifts the
/// body once; descendants must not read [MediaQuery.viewInsets] for layout.
class FullScreenOverlayKeyboardScope extends StatelessWidget {
  const FullScreenOverlayKeyboardScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    return MediaQuery(
      data: data.copyWith(viewInsets: EdgeInsets.zero),
      child: child,
    );
  }

  /// Bottom padding for a footer pinned above the keyboard or home indicator.
  static double pinnedFooterBottomPadding(MediaQueryData media) {
    if (media.viewInsets.bottom > 0) return AppSize.spaceMD;
    return media.viewPadding.bottom + AppSize.spaceMD;
  }
}