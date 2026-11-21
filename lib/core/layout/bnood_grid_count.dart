import 'package:flutter/material.dart';

import 'app_layout.dart';

/// Grid column count for directory-style grids (items phase).
int bnoodGridCount(
  BuildContext context, {
  required int mobile,
  required int tablet,
  required int desktop,
}) {
  if (context.isDesktopLayout) return desktop;
  if (context.isTabletLayout) return tablet;
  return mobile;
}
