import 'package:flutter/material.dart';

import '../../app/widgets/shell_nav_icon.dart';
import '../config/extensions/num_extensions.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_shape.dart';
import '../config/theme/app_size.dart';
import '../resources/gen/assets.gen.dart';

/// One row in [AppOverflowMenu]: localized label, owner SVG icon, tap handler.
class AppOverflowMenuAction {
  const AppOverflowMenuAction({
    required this.label,
    required this.icon,
    required this.onSelected,
    this.destructive = false,
  });

  final String label;
  final SvgGenImage icon;
  final VoidCallback onSelected;
  final bool destructive;
}

/// Overflow (⋮) menu with app surface, superellipse chrome, and leading SVG icons.
class AppOverflowMenu extends StatelessWidget {
  const AppOverflowMenu({
    super.key,
    required this.actions,
    this.buttonKey,
    this.padding = EdgeInsets.zero,
  });

  final List<AppOverflowMenuAction> actions;
  final Key? buttonKey;
  final EdgeInsetsGeometry padding;

  static const _menuMinWidth = 168.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final menuShape = AppShape.superellipse(
      radius: AppSize.radiusMD,
      side: BorderSide(color: colors.outline),
    );

    final dividerTheme = DividerThemeData(
      color: colors.outlineSubtle,
      thickness: AppSize.borderWidthHairline,
      space: 0,
    );

    return Theme(
      data: Theme.of(context).copyWith(dividerTheme: dividerTheme),
      child: PopupMenuButton<int>(
        key: buttonKey,
        padding: padding,
        constraints: const BoxConstraints(minWidth: _menuMinWidth),
        icon: Icon(Icons.more_vert, size: AppSize.icon, color: colors.onSurfaceMuted),
        offset: const Offset(0, AppSize.spaceSM),
        shape: menuShape,
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: colors.buttonShadow.color,
        menuPadding: EdgeInsets.zero,
        onSelected: (index) => actions[index].onSelected(),
        itemBuilder: (context) {
          final entries = <PopupMenuEntry<int>>[];
          for (var i = 0; i < actions.length; i++) {
            if (i > 0) {
              entries.add(const PopupMenuDivider(height: AppSize.borderWidthHairline));
            }
            entries.add(
              PopupMenuItem<int>(
                value: i,
                padding: EdgeInsets.zero,
                height: AppSize.hitMin,
                child: _AppOverflowMenuRow(action: actions[i]),
              ),
            );
          }
          return entries;
        },
      ),
    );
  }
}

class _AppOverflowMenuRow extends StatelessWidget {
  const _AppOverflowMenuRow({required this.action});

  final AppOverflowMenuAction action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final fg = action.destructive ? colors.spend : colors.onSurface;

    return SizedBox(
      height: AppSize.hitMin,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSize.spaceLG),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: AppSize.icon,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: ShellNavIcon(asset: action.icon, color: fg, size: AppSize.icon),
              ),
            ),
            AppSize.spaceMD.gap,
            Expanded(
              child: Text(
                action.label,
                style: text.bodyEmphasis.copyWith(color: fg),
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
