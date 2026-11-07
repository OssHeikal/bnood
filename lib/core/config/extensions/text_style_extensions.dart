import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

extension TextStyleChain on TextStyle {
  TextStyle get tabularFigures => copyWith(fontFeatures: const [ui.FontFeature.tabularFigures()]);
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);

  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  TextStyle get underline => copyWith(decoration: TextDecoration.underline);

  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);

  TextStyle get ellipsis => copyWith(overflow: TextOverflow.ellipsis);

  TextStyle setColor(Color color) => copyWith(color: color);

  TextStyle setHeight(double height) => copyWith(height: height);
}
