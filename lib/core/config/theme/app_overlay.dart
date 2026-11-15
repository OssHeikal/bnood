import 'package:flutter/material.dart';

/// Modal / dialog scrim colors (bottom sheets, dialogs, in-route overlays).
abstract final class AppOverlay {
  static const lightScrim = Color(0x591A2422);
  static const darkScrim = Color(0x99000000);

  static Color barrierColor(BuildContext context) {
    return barrierColorForBrightness(Theme.of(context).brightness);
  }

  static Color barrierColorForBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? darkScrim : lightScrim;
  }
}