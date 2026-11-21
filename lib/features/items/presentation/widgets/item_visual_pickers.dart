import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_shape.dart';
import '../../../../core/config/theme/app_size.dart';
import '../../data/item_api_record.dart';
import '../item_semantic_icon.dart';

/// Icon grid + color swatches shared by the item create and edit sheets.
class ItemVisualPickers extends StatelessWidget {
  const ItemVisualPickers({
    super.key,
    required this.catalog,
    required this.selectedIconKey,
    required this.selectedColorKey,
    required this.onIconKey,
    required this.onColorKey,
  });

  final ItemIconsCatalog catalog;
  final String selectedIconKey;
  final String selectedColorKey;
  final ValueChanged<String> onIconKey;
  final ValueChanged<String> onColorKey;

  /// Minimum square cell for one icon; actual cells stretch to fill the row evenly.
  static const iconCellMin = 52.0;
  static const iconCellSpacing = AppSize.spaceMD;
  static const colorSwatchSize = 36.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = context.text;
    final accent = itemSemanticAccentColor(selectedColorKey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.itemPickColorLabel, style: text.caption.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSize.spaceSM),
        Wrap(
          spacing: AppSize.spaceMD,
          runSpacing: AppSize.spaceMD,
          children: [
            for (final option in catalog.colors)
              _ColorSwatch(
                colorKey: option.key,
                color: itemSemanticAccentColor(option.key),
                selected: option.key == selectedColorKey,
                onTap: () => onColorKey(option.key),
              ),
          ],
        ),
        const SizedBox(height: AppSize.spaceLG),
        Text(l10n.itemPickIconLabel, style: text.caption.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSize.spaceSM),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = ((width + iconCellSpacing) / (iconCellMin + iconCellSpacing)).floor().clamp(1, 12);
            final cell = (width - iconCellSpacing * (columns - 1)) / columns;
            return Wrap(
              spacing: iconCellSpacing,
              runSpacing: iconCellSpacing,
              children: [
                for (final key in catalog.iconKeys)
                  _IconCell(
                    key: ValueKey('item_icon_$key'),
                    iconKey: key,
                    size: cell,
                    accent: accent,
                    selected: key == selectedIconKey,
                    onTap: () => onIconKey(key),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _IconCell extends StatelessWidget {
  const _IconCell({
    super.key,
    required this.iconKey,
    required this.size,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final String iconKey;
  final double size;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = AppShape.superellipse(
      radius: AppSize.radiusMD,
      side: BorderSide(
        color: selected ? accent : colors.outlineSubtle,
        width: selected ? AppSize.focusWidth : AppSize.borderWidth,
      ),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: iconKey,
      child: Material(
        color: selected ? accent.withValues(alpha: 0.14) : colors.surfaceSunken,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: itemSemanticIconWidget(
                iconKey: iconKey,
                color: selected ? accent : colors.onSurfaceMuted,
                size: AppSize.icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.colorKey, required this.color, required this.selected, required this.onTap});

  final String colorKey;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      key: ValueKey('item_color_$colorKey'),
      label: colorKey,
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: ItemVisualPickers.colorSwatchSize,
          height: ItemVisualPickers.colorSwatchSize,
          padding: const EdgeInsets.all(AppSize.spaceXS),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: selected ? color : Colors.transparent, width: AppSize.focusWidth),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: selected ? Icon(Icons.check_rounded, size: AppSize.iconSmall, color: colors.onSolid) : null,
          ),
        ),
      ),
    );
  }
}
