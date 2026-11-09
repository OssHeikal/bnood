import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/theme/app_colors.dart';
import '../config/theme/app_shape.dart';
import '../config/theme/app_size.dart';
import '../formatting/display_digits.dart';
import '../utils/extensions/bidi_isolate.dart';
import 'app_pressable.dart';

/// Product app bar: canvas, flat, title at logical start, [AppText.pageTitle].
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleLtr = false,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.bottom,
  });

  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final bool subtitleLtr;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  static const double _subtitleToolbarHeight = 64;

  bool get _hasSubtitle {
    final sub = subtitle?.trim();
    return sub != null && sub.isNotEmpty;
  }

  double get _toolbarHeight => _hasSubtitle ? _subtitleToolbarHeight : kToolbarHeight;

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(_toolbarHeight + bottomHeight);
  }

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
      toolbarHeight: _toolbarHeight,
      systemOverlayStyle: overlay.copyWith(statusBarColor: Colors.transparent),
      iconTheme: IconThemeData(color: colors.onSurface),
      actionsIconTheme: IconThemeData(color: colors.onSurface),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: titleWidget ?? _buildTitle(context),
      bottom: bottom,
      actions: _wrapActions(actions),
    );
  }

  Widget? _buildTitle(BuildContext context) {
    final titleText = title?.trim();
    if (titleText == null || titleText.isEmpty) return null;
    final text = context.text;
    final colors = context.colors;
    final sub = subtitle?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          titleText,
          style: text.pageTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (sub != null && sub.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitleLtr ? LtrIsolate.isolate(DisplayDigits.toWesternDigits(sub)) : sub,
            style: text.caption.copyWith(color: colors.onSurfaceMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  List<Widget>? _wrapActions(List<Widget>? actions) {
    if (actions == null || actions.isEmpty) return actions;
    final last = actions.length - 1;
    return [
      for (var i = 0; i < actions.length; i++)
        Padding(
          padding: EdgeInsetsDirectional.only(
            end: i == last ? AppSize.spaceMD : AppSize.spaceXS,
          ),
          child: actions[i],
        ),
    ];
  }
}

enum CustomAppBarActionTone { tint, surface }

/// Square app-bar icon control (tint add vs surface utility).
class CustomAppBarAction extends StatelessWidget {
  const CustomAppBarAction({
    super.key,
    required this.tooltip,
    required this.onPressed,
    required this.child,
    this.enabled = true,
    this.tone = CustomAppBarActionTone.surface,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final Widget child;
  final bool enabled;
  final CustomAppBarActionTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = switch (tone) {
      CustomAppBarActionTone.tint => colors.accentTeal.tint,
      CustomAppBarActionTone.surface => colors.surface,
    };
    return Tooltip(
      message: tooltip,
      child: AppPressable(
        enabled: enabled,
        onPressed: onPressed,
        child: Material(
          color: background,
          shape: AppShape.superellipse(radius: AppSize.radiusSM),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: AppSize.buttonHeight,
            height: AppSize.buttonHeight,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

