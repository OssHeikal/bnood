import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/items/item_api_record.dart';
import '../item_semantic_icon.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = context.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.itemPickIconLabel, style: text.caption.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSize.spaceSM),
        Wrap(
          spacing: AppSize.spaceSM,
          runSpacing: AppSize.spaceSM,
          children: [
            for (final key in catalog.iconKeys)
              _IconChip(
                iconKey: key,
                selected: key == selectedIconKey,
                onTap: () => onIconKey(key),
              ),
          ],
        ),
        const SizedBox(height: AppSize.spaceMD),
        Text(l10n.itemPickColorLabel, style: text.caption.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSize.spaceSM),
        Wrap(
          spacing: AppSize.spaceSM,
          runSpacing: AppSize.spaceSM,
          children: [
            for (final option in catalog.colors)
              _ColorChip(
                colorKey: option.key,
                color: itemSemanticAccentColor(option.key),
                selected: option.key == selectedColorKey,
                onTap: () => onColorKey(option.key),
              ),
          ],
        ),
      ],
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.iconKey,
    required this.selected,
    required this.onTap,
  });

  final String iconKey;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = itemSemanticAccentColor('teal');
    return Material(
      color: selected ? accent.withValues(alpha: 0.15) : colors.surface,
      shape: AppShape.superellipse(radius: AppSize.radiusSM),
      child: InkWell(
        onTap: onTap,
        customBorder: AppShape.superellipse(radius: AppSize.radiusSM),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: itemSemanticIconWidget(iconKey: iconKey, color: accent),
          ),
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.colorKey,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String colorKey;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: colorKey,
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: selected ? Border.all(color: Colors.white, width: 2) : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
