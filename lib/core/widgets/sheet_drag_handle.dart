import 'package:flutter/material.dart';

import '../config/theme/app_size.dart';
import '../config/theme/app_colors.dart';

/// The drag affordance at the top of a bottom sheet.
class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Center(
        child: Container(
          width: AppSize.avatar * 0.75,
          height: AppSize.spaceXS,
          decoration: BoxDecoration(
            color: context.colors.outlineSubtle,
            borderRadius: BorderRadius.circular(AppSize.radius),
          ),
        ),
      ),
    );
  }
}
