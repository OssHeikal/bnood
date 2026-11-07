import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_shape.dart';
import '../../config/theme/app_size.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius,
    this.circle = false,
    this.onPage = false,
  }) : _pill = false;

  const SkeletonBox.pill({
    super.key,
    this.width,
    required this.height,
    this.onPage = false,
  })  : radius = null,
        circle = false,
        _pill = true;

  const SkeletonBox.round({
    super.key,
    required double size,
    this.onPage = false,
  })  : width = size,
        height = size,
        radius = null,
        circle = true,
        _pill = false;

  final double? width;
  final double height;
  final double? radius;
  final bool circle;
  final bool onPage;
  final bool _pill;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fill = onPage ? colors.outlineSubtle : colors.surfaceSunken;
    if (circle) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
      );
    }
    final corner = radius ?? AppSize.radiusMD;
    final shape = _pill ? StadiumBorder() : AppShape.superellipse(radius: corner);
    return Material(
      color: fill,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(width: width, height: height),
    );
  }
}
