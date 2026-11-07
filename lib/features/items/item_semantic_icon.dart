import 'package:flutter/material.dart';

import '../../core/resources/gen/assets.gen.dart';
import '../../core/theme/app_colors.dart';

/// Maps seeded [iconName] to owner FlutterGen outline assets.
SvgGenImage itemSemanticIconAsset(String iconName) {
  return switch (iconName) {
    'layers' => Assets.icons.itemsLayersOutline,
    'bathtub' => Assets.icons.bathtubOutline,
    'plumbing' => Assets.icons.materialsPackageOutline,
    'electrical_services' => Assets.icons.electricalPlugOutline,
    'dashboard' => Assets.icons.dashboardOutline,
    'brush' || 'format_paint' => Assets.icons.paintRollerOutline,
    'kitchen' => Assets.icons.homeRoundedOutline,
    'window' => Assets.icons.keyOutline,
    'ac_unit' => Assets.icons.filterSlidersOutline,
    'light' => Assets.icons.infoCircleOutline,
    'engineering' => Assets.icons.laborHardHatOutline,
    'local_shipping' => Assets.icons.cardTransferOutline,
    'construction' => Assets.icons.carpentryHammerOutline,
    _ => Assets.icons.categoriesOutline,
  };
}

Color itemSemanticAccentColor(String colorKey) => AppColors.accent(colorKey);
