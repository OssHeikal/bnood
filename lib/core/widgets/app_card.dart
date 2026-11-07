import 'package:flutter/material.dart';

import '../config/theme/app_colors.dart';
import '../config/theme/app_shape.dart';
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

  @visibleForTesting
  static Gradient? statCardGradient(
    AppCardPreset preset,
    AppColors colors,
    Brightness brightness,
  ) {
    const begin = AlignmentDirectional(-0.9, -1);
    const end = AlignmentDirectional(0.9, 1);
    if (brightness == Brightness.light) {
      return switch (preset) {
        AppCardPreset.statReceive => const LinearGradient(
            begin: begin,
            end: end,
            colors: [Color(0xFFE8F8EF), Color(0xFFF5FCF8)],
          ),
        AppCardPreset.statSpend => const LinearGradient(
            begin: begin,
            end: end,
            colors: [Color(0xFFFCECEC), Color(0xFFFEF7F7)],
          ),
        AppCardPreset.statRemaining => const LinearGradient(
            begin: begin,
            end: end,
            colors: [Color(0xFFE6F6F4), Color(0xFFF3FBFA)],
          ),
        AppCardPreset.plain => null,
      };
    }
    Color blendTint(Color tint) => Color.lerp(tint, colors.surface, 0.5)!;
    return switch (preset) {
      AppCardPreset.statReceive => LinearGradient(
          begin: begin,
          end: end,
          colors: [colors.successBg, blendTint(colors.successBg)],
        ),
      AppCardPreset.statSpend => LinearGradient(
          begin: begin,
          end: end,
          colors: [colors.errorBg, blendTint(colors.errorBg)],
        ),
      AppCardPreset.statRemaining => LinearGradient(
          begin: begin,
          end: end,
          colors: [colors.infoBg, blendTint(colors.infoBg)],
        ),
      AppCardPreset.plain => null,
    };
  }

  Gradient? _statGradient(BuildContext context) {
    return statCardGradient(preset, context.colors, Theme.of(context).brightness);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedGradient = gradient ?? _statGradient(context);
    final fill = background ?? colors.surface;
    final shape = AppShape.superellipse(
      radius: radius,
      side: borderWidth > 0 ? BorderSide(color: borderColor ?? colors.outline, width: borderWidth) : BorderSide.none,
    );

    final surface = Material(
      color: resolvedGradient == null ? fill : Colors.transparent,
      elevation: 0,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      shape: shape,
      child: Ink(
        decoration: resolvedGradient == null
            ? null
            : BoxDecoration(
                gradient: resolvedGradient,
              ),
        child: Padding(padding: padding, child: child),
      ),
    );

    final shadowed = DecoratedBox(
      decoration: BoxDecoration(boxShadow: shadow ?? [colors.buttonShadow]),
      child: surface,
    );

    if (onTap == null) return shadowed;
    return AppPressable(onPressed: onTap, child: shadowed);
  }
}
