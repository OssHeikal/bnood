import 'package:flutter/material.dart';

import '../config/theme/app_colors.dart';
import '../config/theme/app_size.dart';
import 'app_pressable.dart';

enum AppCardPreset { plain, statReceive, statSpend, statRemaining }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSize.spaceLG),
    this.radius = AppSize.radiusMD,
    this.background,
    this.gradient,
    this.borderColor,
    this.borderWidth = 0,
    this.shadow,
    this.onTap,
    this.preset = AppCardPreset.plain,
  });

  factory AppCard.statReceive({required Widget child, VoidCallback? onTap}) {
    return AppCard(preset: AppCardPreset.statReceive, onTap: onTap, child: child);
  }

  factory AppCard.statSpend({required Widget child, VoidCallback? onTap}) {
    return AppCard(preset: AppCardPreset.statSpend, onTap: onTap, child: child);
  }

  factory AppCard.statRemaining({required Widget child, VoidCallback? onTap}) {
    return AppCard(preset: AppCardPreset.statRemaining, onTap: onTap, child: child);
  }

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? background;
  final Gradient? gradient;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;
  final AppCardPreset preset;

  BoxDecoration _decoration(AppColors colors) {
    final statGradient = switch (preset) {
      AppCardPreset.statReceive => const LinearGradient(
          begin: AlignmentDirectional(-0.9, -1),
          end: AlignmentDirectional(0.9, 1),
          colors: [Color(0xFFE8F8EF), Color(0xFFF5FCF8)],
        ),
      AppCardPreset.statSpend => const LinearGradient(
          begin: AlignmentDirectional(-0.9, -1),
          end: AlignmentDirectional(0.9, 1),
          colors: [Color(0xFFFCECEC), Color(0xFFFEF7F7)],
        ),
      AppCardPreset.statRemaining => const LinearGradient(
          begin: AlignmentDirectional(-0.9, -1),
          end: AlignmentDirectional(0.9, 1),
          colors: [Color(0xFFE6F6F4), Color(0xFFF3FBFA)],
        ),
      AppCardPreset.plain => null,
    };

    return BoxDecoration(
      color: gradient == null && statGradient == null ? (background ?? colors.surface) : null,
      gradient: gradient ?? statGradient,
      borderRadius: BorderRadius.circular(radius),
      border: borderWidth > 0 ? Border.all(color: borderColor ?? colors.outline, width: borderWidth) : null,
      boxShadow: shadow ?? [colors.buttonShadow],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final surface = DecoratedBox(
      decoration: _decoration(colors),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return surface;
    return AppPressable(onPressed: onTap, child: surface);
  }
}
