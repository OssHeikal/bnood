import 'package:flutter/material.dart';

import '../../core/config/theme/app_colors.dart';

/// Merges foundation [AppColors]/[AppText] onto the current theme for home only.
class HomeFoundationScope extends StatelessWidget {
  const HomeFoundationScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final colors = base.brightness == Brightness.dark ? AppColors.dark : AppColors.light;
    final text = AppText.fromColors(colors);
    final merged = Map<Object, ThemeExtension<dynamic>>.from(base.extensions);
    merged[AppColors] = colors;
    merged[AppText] = text;
    return Theme(
      data: base.copyWith(
        scaffoldBackgroundColor: colors.canvas,
        extensions: merged.values,
      ),
      child: child,
    );
  }
}
