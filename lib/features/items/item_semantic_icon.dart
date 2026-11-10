import 'package:flutter/material.dart';

import '../../core/items/item_icon_catalog.dart';
import '../../core/theme/app_colors.dart' as legacy;
import '../../core/resources/gen/assets.gen.dart';

Color itemSemanticAccentColor(String colorKey) => legacy.AppColors.accent(colorKey);

/// Maps legacy Material keys from older API payloads to the outline catalog.
String resolveItemIconKey(String iconKey) {
  if (itemIconCatalogKeys.contains(iconKey)) {
    return iconKey;
  }
  return switch (iconKey) {
    'construction' => 'pickaxe',
    'format_paint' => 'brick_wall',
    'plumbing' => 'sink',
    'electrical_services' => 'plug_socket',
    'dashboard' => 'dashboard_square',
    'brush' => 'paint_roller',
    'door_front_door' => 'door',
    'kitchen' => 'refrigerator',
    'window' => 'windows',
    'ac_unit' => 'smart_ac',
    'light' => 'lamp',
    'engineering' => 'hard_hat',
    'local_shipping' => 'pickup',
    'category' => 'grid_table',
    _ => 'tools',
  };
}

SvgGenImage? itemSemanticIconAsset(String iconKey) {
  final resolved = resolveItemIconKey(iconKey);
  return switch (resolved) {
    'paint_roller' => Assets.itemIcons.paintRoller,
    'brick_wall' => Assets.itemIcons.brickWall,
    'plug_socket' => Assets.itemIcons.plugSocket,
    'sink' => Assets.itemIcons.sink,
    'toilet' => Assets.itemIcons.toilet,
    'bathtub' => Assets.itemIcons.bathtub,
    'door' => Assets.itemIcons.door,
    'windows' => Assets.itemIcons.windows,
    'smart_ac' => Assets.itemIcons.smartAc,
    'lamp' => Assets.itemIcons.lamp,
    'hammer' => Assets.itemIcons.hammer,
    'drill' => Assets.itemIcons.drill,
    'wrench' => Assets.itemIcons.wrench,
    'tools' => Assets.itemIcons.tools,
    'shovel' => Assets.itemIcons.shovel,
    'pickaxe' => Assets.itemIcons.pickaxe,
    'hard_hat' => Assets.itemIcons.hardHat,
    'pickup' => Assets.itemIcons.pickup,
    'sofa' => Assets.itemIcons.sofa,
    'sofa_single' => Assets.itemIcons.sofaSingle,
    'bed_single' => Assets.itemIcons.bedSingle,
    'desk' => Assets.itemIcons.desk,
    'mirror' => Assets.itemIcons.mirror,
    'refrigerator' => Assets.itemIcons.refrigerator,
    'grid_table' => Assets.itemIcons.gridTable,
    'dashboard_square' => Assets.itemIcons.dashboardSquare,
    'layers' => Assets.itemIcons.layers,
    _ => null,
  };
}

Widget itemSemanticIconWidget({
  required String iconKey,
  required Color color,
  double size = 20,
}) {
  final asset = itemSemanticIconAsset(iconKey) ?? Assets.itemIcons.tools;
  return asset.svg(
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    excludeFromSemantics: true,
  );
}
