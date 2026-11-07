import 'package:flutter/material.dart';

import '../config/theme/app_size.dart';

enum AppChevronAxis { forward, back, left, right }

/// Disclosure and navigation chevrons. [AppChevron.forward] points toward the trailing edge in LTR and RTL.
class AppChevron extends StatelessWidget {
  const AppChevron.forward({super.key, this.size, this.color})
    : axis = AppChevronAxis.forward;

  const AppChevron.back({super.key, this.size, this.color})
    : axis = AppChevronAxis.back;

  const AppChevron.left({super.key, this.size, this.color})
    : axis = AppChevronAxis.left;

  const AppChevron.right({super.key, this.size, this.color})
    : axis = AppChevronAxis.right;

  final AppChevronAxis axis;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final resolvedSize = size ?? theme.size ?? AppSize.iconCompact;
    final resolvedColor = color ?? theme.color;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    // Pin LTR so IconData.matchTextDirection does not mirror with a Transform.
    final (IconData iconData, TextDirection textDirection) = switch (axis) {
      AppChevronAxis.forward => (
        rtl ? Icons.chevron_left : Icons.chevron_right,
        TextDirection.ltr,
      ),
      AppChevronAxis.back => (
        rtl ? Icons.chevron_right : Icons.chevron_left,
        TextDirection.ltr,
      ),
      AppChevronAxis.left => (Icons.chevron_left, TextDirection.ltr),
      AppChevronAxis.right => (Icons.chevron_right, TextDirection.ltr),
    };

    return Icon(
      iconData,
      size: resolvedSize,
      color: resolvedColor,
      textDirection: textDirection,
    );
  }
}
