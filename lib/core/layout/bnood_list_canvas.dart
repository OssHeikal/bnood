import 'package:flutter/material.dart';

import 'bnood_layout.dart';
import 'bnood_max_width.dart';

/// Centers menu / settings-style screens at [BnoodLayout.listMaxWidth] on tablet+.
class BnoodListCanvas extends StatelessWidget {
  const BnoodListCanvas({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsDirectional? padding;

  @override
  Widget build(BuildContext context) {
    return BnoodMaxWidth(
      maxWidth: BnoodLayout.listMaxWidth,
      padding: padding,
      child: child,
    );
  }
}
