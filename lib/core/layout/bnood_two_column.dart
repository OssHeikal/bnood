import 'package:flutter/material.dart';

import 'bnood_layout.dart';

/// Side-by-side on tablet+; stacked on phone (for later list/detail phases).
class BnoodTwoColumn extends StatelessWidget {
  const BnoodTwoColumn({
    super.key,
    required this.start,
    required this.end,
    this.spacing = 24,
    this.startFlex = 1,
    this.endFlex = 1,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final Widget start;
  final Widget end;
  final double spacing;
  final int startFlex;
  final int endFlex;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (context.isBnoodMobile) {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          start,
          SizedBox(height: spacing),
          end,
        ],
      );
    }
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Expanded(flex: startFlex, child: start),
        SizedBox(width: spacing),
        Expanded(flex: endFlex, child: end),
      ],
    );
  }
}
