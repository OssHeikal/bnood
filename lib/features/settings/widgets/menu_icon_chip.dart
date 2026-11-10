import 'package:flutter/material.dart';

import '../../../app/widgets/shell_nav_icon.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/resources/gen/assets.gen.dart';

/// Small rounded chip for menu row leading icons (theme-tinted).
class MenuIconChip extends StatelessWidget {
  const MenuIconChip({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final SvgGenImage icon;
  final Color backgroundColor;
  final Color iconColor;

  static const double _chipSize = 40;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSize.radiusSM),
      ),
      child: SizedBox(
        width: _chipSize,
        height: _chipSize,
        child: Center(
          child: ShellNavIcon(
            asset: icon,
            color: iconColor,
            size: AppSize.icon,
          ),
        ),
      ),
    );
  }
}
