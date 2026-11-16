import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_breakpoints.dart';
import 'app_layout.dart';

/// Centers full-screen form routes in a phone-width column on tablet+.
class AppFormRouteCanvas extends StatelessWidget {
  const AppFormRouteCanvas({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= AppBreakpoints.mobileMax) return child;
        final theme = Theme.of(context);
        final panelWidth = math.min(AppLayout.formMaxWidth, constraints.maxWidth);
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