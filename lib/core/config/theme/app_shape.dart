import 'package:flutter/material.dart';

import 'app_size.dart';

/// Shared corner geometry. Default surfaces use [RoundedSuperellipseBorder] (Flutter 3.41).
///
/// Owner exceptions (do not use superellipse here):
/// - Shell nav pill + selected tab overlay: [stadium]
/// - Voucher satellite + avatars marked circular: [circle] / [CircleBorder]
abstract final class AppShape {
  static ShapeBorder superellipse({double radius = AppSize.radiusMD, BorderSide side = BorderSide.none}) {
    return RoundedSuperellipseBorder(side: side, borderRadius: BorderRadius.circular(radius));
  }

  static const ShapeBorder stadium = StadiumBorder();
  static const ShapeBorder circle = CircleBorder();
}
