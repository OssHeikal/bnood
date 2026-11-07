import 'package:flutter/material.dart';

import '../config/theme/app_size.dart';

/// Temporary Material icon chrome until owner SVG set lands.
class FoundationIcon extends StatelessWidget {
  const FoundationIcon(this.icon, {super.key, this.size, this.color});

  final IconData icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size ?? AppSize.iconCompact, color: color);
  }
}
