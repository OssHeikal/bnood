import 'package:flutter/material.dart';

import 'bnood_layout.dart';

/// Grid column count for directory-style grids (items phase).
int bnoodGridCount(BuildContext context, {required int mobile, required int tablet, required int desktop}) {
  if (context.isBnoodDesktop) return desktop;
  if (context.isBnoodTablet) return tablet;
  return mobile;
}
