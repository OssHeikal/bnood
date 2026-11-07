import 'dart:ui';

import 'package:flutter/painting.dart';

abstract final class AppFont {
  static const family = 'Cairo';

  /// Cairo-Regular.ttf ships with a verified `wght` axis (200–1000).
  static const variationsRegular = <FontVariation>[FontVariation('wght', 400)];

  static TextStyle cairo({required double wght, TextStyle? base}) {
    return (base ?? const TextStyle(fontFamily: family)).copyWith(
      fontFamily: family,
      fontVariations: [FontVariation('wght', wght)],
    );
  }

  static TextStyle w400(TextStyle style) => cairo(wght: 400, base: style);
  static TextStyle w500(TextStyle style) => cairo(wght: 500, base: style);
  static TextStyle w600(TextStyle style) => cairo(wght: 600, base: style);
  static TextStyle w700(TextStyle style) => cairo(wght: 700, base: style);
}
