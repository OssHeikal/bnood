import 'package:flutter/material.dart';

import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_card.dart';
import '../item_semantic_icon.dart';

class ItemCatalogTile extends StatelessWidget {
  const ItemCatalogTile({
    super.key,
    required this.name,
    required this.colorKey,
    required this.iconName,
    required this.onOpenEdit,
  });

  final String name;
  final String colorKey;
  final String iconName;
  final VoidCallback onOpenEdit;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;
    final accent = itemSemanticAccentColor(colorKey);
    final icon = itemSemanticIconAsset(iconName);
    final surface = colors.surface;

    return AppCard(
      padding: const EdgeInsets.all(AppSize.spaceLG),
      gradient: LinearGradient(
        begin: const AlignmentDirectional(-0.9, -1),
        end: const AlignmentDirectional(0.9, 1),
        colors: [
          Color.lerp(surface, accent, 0.20)!,
          Color.lerp(surface, accent, 0.07)!,
        ],
      ),
      onTap: onOpenEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: accent.withValues(alpha: 0.18),
            shape: AppShape.superellipse(radius: AppSize.radiusSM),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: icon.svg(
                  width: AppSize.iconSmall,
                  height: AppSize.iconSmall,
                  colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            name,
            style: text.bodyEmphasis,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
