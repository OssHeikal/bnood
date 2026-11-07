import 'package:flutter/material.dart';

import '../config/theme/app_colors.dart';
import '../config/theme/app_size.dart';
import '../resources/gen/assets.gen.dart';

/// Compact selectable row for in-sheet entity lists (not [AppCard] tiles).
class EntityPickerOptionRow extends StatelessWidget {
  const EntityPickerOptionRow({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.leadingWidth,
    required this.leading,
    required this.title,
    this.subtitle,
    this.showDivider = true,
    this.semanticLabel,
  });

  final bool selected;
  final VoidCallback onSelect;
  final double leadingWidth;
  final Widget leading;
  final String title;
  final Widget? subtitle;
  final bool showDivider;
  final String? semanticLabel;

  static double dividerStartInset(double leadingWidth) =>
      AppSize.screenPadding + leadingWidth + AppSize.spaceMD;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final dividerInset = dividerStartInset(leadingWidth);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          selected: selected,
          label: semanticLabel ?? title,
          child: Material(
            color: selected ? colors.primaryTint : Colors.transparent,
            child: InkWell(
              onTap: onSelect,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: AppSize.screenPadding,
                  end: AppSize.screenPadding,
                  top: AppSize.spaceMD,
                  bottom: AppSize.spaceMD,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: leadingWidth, height: leadingWidth, child: leading),
                    const SizedBox(width: AppSize.spaceMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            title,
                            style: text.bodyEmphasis,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: AppSize.spaceXS),
                            DefaultTextStyle(
                              style: text.caption.copyWith(color: colors.onSurfaceMuted),
                              child: subtitle!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: AppSize.spaceSM),
                      Semantics(
                        selected: true,
                        label: 'Selected',
                        child: Assets.icons.checkOutline.svg(
                          width: AppSize.iconSmall,
                          height: AppSize.iconSmall,
                          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: AppSize.borderWidthHairline,
            indent: dividerInset,
            endIndent: 0,
            color: colors.outline,
          ),
      ],
    );
  }
}
