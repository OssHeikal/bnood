import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart' as legacy;

/// Material icons keyed by server `icon_key` values.
IconData itemSemanticIconData(String iconKey) => switch (iconKey) {
      'layers' => Icons.layers_outlined,
      'bathtub' => Icons.bathtub_outlined,
      'plumbing' => Icons.plumbing_outlined,
      'electrical_services' => Icons.electrical_services_outlined,
      'dashboard' => Icons.dashboard_outlined,
      'brush' => Icons.brush_outlined,
      'format_paint' => Icons.format_paint_outlined,
      'kitchen' => Icons.kitchen_outlined,
      'window' => Icons.window_outlined,
      'ac_unit' => Icons.ac_unit_outlined,
      'light' => Icons.light_outlined,
      'engineering' => Icons.engineering_outlined,
      'local_shipping' => Icons.local_shipping_outlined,
      'construction' => Icons.construction_outlined,
      'door_front_door' => Icons.door_front_door_outlined,
      'category' => Icons.category_outlined,
      _ => Icons.category_outlined,
    };

Color itemSemanticAccentColor(String colorKey) => legacy.AppColors.accent(colorKey);

Widget itemSemanticIconWidget({
  required String iconKey,
  required Color color,
  double size = 20,
}) {
  return Icon(
    itemSemanticIconData(iconKey),
    size: size,
    color: color,
  );
}
