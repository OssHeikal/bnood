import 'package:flutter/widgets.dart';

import '../../core/ui/resources/gen/assets.gen.dart';

class ShellNavDestination {
  const ShellNavDestination({
    required this.label,
    required this.semanticsLabel,
    this.icon,
    this.tabBuilder,
  }) : assert(icon != null || tabBuilder != null);

  final String label;
  final String semanticsLabel;
  final SvgGenImage? icon;

  /// When set, replaces the default dock / rail tab control (e.g. More avatar).
  final Widget Function(
    BuildContext context, {
    required bool selected,
    required double labelSize,
    required VoidCallback onTap,
  })? tabBuilder;
}
