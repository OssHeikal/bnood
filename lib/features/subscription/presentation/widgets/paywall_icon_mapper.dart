import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/ui/resources/gen/assets.gen.dart';

/// Maps backend benefit icon keys to bundled SVG assets.
Widget paywallBenefitIcon(
  String key, {
  double size = 18,
  Color color = const Color(0xFF0F9D8E),
}) {
  final asset = switch (key) {
    'projects' || 'projects_grid' => Assets.icons.calendarGridOutline,
    'ledger' => Assets.icons.balanceWalletOutline,
    'pdf' || 'pdf_statement' || 'pdf_export' => Assets.icons.pdfOutline,
    'directory' => Assets.icons.directoryOutline,
    'team' ||
    'organizations' ||
    'team_permissions' => Assets.icons.itemsLayersOutline,
    'web_dashboard' => Assets.icons.dashboardOutline,
    'shield' => Assets.icons.shield02Outline,
    'spark' || _ => Assets.icons.crownOutline,
  };

  return SvgPicture.asset(
    asset.path,
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );
}
