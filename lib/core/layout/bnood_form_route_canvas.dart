import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'bnood_breakpoints.dart';
import 'bnood_layout.dart';

/// Centers full-screen form routes in a phone-width column on tablet+.
class BnoodFormRouteCanvas extends StatelessWidget {
  const BnoodFormRouteCanvas({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= BnoodBreakpoints.mobileMax) return child;
        final theme = Theme.of(context);
        final panelWidth = math.min(BnoodLayout.formMaxWidth, constraints.maxWidth);
        return ColoredBox(
          color: theme.scaffoldBackgroundColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              SizedBox(
                width: panelWidth,
                child: child,
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}
