import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/theme/app_colors.dart';
import 'foundation_app_bar_title.dart';

/// App bar chrome aligned with [HomeFoundationScope] semantic colors (light/dark).
class FoundationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FoundationAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.actions,
  });

  final String title;
  final Widget? titleWidget;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlay = isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    return AppBar(
      backgroundColor: colors.canvas,
      foregroundColor: colors.onSurface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: overlay.copyWith(statusBarColor: Colors.transparent),
      iconTheme: IconThemeData(color: colors.onSurface),
      actionsIconTheme: IconThemeData(color: colors.onSurface),
      title: titleWidget ?? FoundationAppBarTitle(title: title),
      actions: actions,
    );
  }
}
