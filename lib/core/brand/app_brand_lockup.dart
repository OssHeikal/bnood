import 'package:flutter/material.dart';

import '../resources/gen/assets.gen.dart';

/// Arabic-only بنود lockups from approved layered brand pack.
///
/// Picks **primary (teal)** on light surfaces and **white (inverse)** on dark
/// surfaces so cutouts stay transparent (no white bounding box).
enum AppBrandLockupKind { horizontal, vertical, hero, symbol }

class AppBrandLockup extends StatelessWidget {
  const AppBrandLockup({
    super.key,
    required this.kind,
    this.height,
    this.width,
    this.onDarkSurface,
  });

  final AppBrandLockupKind kind;
  final double? height;
  final double? width;

  /// When null, inferred from [ThemeData.brightness].
  final bool? onDarkSurface;

  bool _useInverse(BuildContext context) {
    if (onDarkSurface != null) return onDarkSurface!;
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    final inverse = _useInverse(context);
    final svg = switch (kind) {
      AppBrandLockupKind.horizontal =>
        inverse ? Assets.brand.logoArHorizontalWhiteSvg : Assets.brand.logoArHorizontalPrimarySvg,
      AppBrandLockupKind.vertical =>
        inverse ? Assets.brand.logoArVerticalWhiteSvg : Assets.brand.logoArVerticalPrimarySvg,
      AppBrandLockupKind.hero =>
        inverse ? Assets.brand.heroArDarkSvg : Assets.brand.heroArLightSvg,
      AppBrandLockupKind.symbol => inverse ? Assets.brand.iconWhiteSvg : Assets.brand.iconPrimarySvg,
    };
    return svg.svg(
      height: height,
      width: width,
      fit: BoxFit.contain,
    );
  }
}

/// Raster lockup for PDF / non-SVG consumers (Arabic horizontal primary).
class AppBrandPdfLogo {
  AppBrandPdfLogo._();

  static const String horizontalPrimaryPng = 'assets/brand/logo_ar_horizontal_primary@2x.png';
}
