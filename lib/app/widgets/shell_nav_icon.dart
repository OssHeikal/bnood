import 'package:flutter/material.dart';

import '../../core/resources/gen/assets.gen.dart';

/// Monochrome outline SVG from owner set; tint via [ColorFilter], not asset edits.
class ShellNavIcon extends StatelessWidget {
  const ShellNavIcon({
    super.key,
    required this.asset,
    required this.color,
    this.size = 20,
    this.semanticsLabel,
  });

  final SvgGenImage asset;
  final Color color;
  final double size;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return asset.svg(
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: semanticsLabel == null,
    );
  }
}
