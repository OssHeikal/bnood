import 'package:flutter/material.dart';

import '../config/theme/app_size.dart';
import 'bnood_grid_count.dart';
import 'bnood_layout.dart';

/// Stacks on phone; fixed column count on tablet+ (directory-style lists).
class BnoodColumnGrid extends StatelessWidget {
  const BnoodColumnGrid({
    super.key,
    required this.children,
    this.spacing = AppSize.spaceMD,
    this.columnsTablet = 2,
    this.columnsDesktop = 2,
  });

  final List<Widget> children;
  final double spacing;
  final int columnsTablet;
  final int columnsDesktop;

  @override
  Widget build(BuildContext context) {
    final columns = context.isBnoodMobile
        ? 1
        : bnoodGridCount(
            context,
            mobile: 1,
            tablet: columnsTablet,
            desktop: columnsDesktop,
          );
    if (columns <= 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: spacing),
            children[i],
          ],
        ],
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      if (rows.isNotEmpty) rows.add(SizedBox(height: spacing));
      rows.add(
        IntrinsicHeight(
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var c = 0; c < columns; c++) ...[
              if (c > 0) SizedBox(width: spacing),
              Expanded(
                child: i + c < children.length ? children[i + c] : const SizedBox.shrink(),
              ),
            ],
          ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}
