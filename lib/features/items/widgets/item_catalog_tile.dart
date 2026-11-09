import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';

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
    required this.iconKey,
    this.isDefault = false,
    required this.onOpenEdit,
  });

  final String name;
  final String colorKey;
  final String iconKey;
  final bool isDefault;
  final VoidCallback? onOpenEdit;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final accent = itemSemanticAccentColor(colorKey);
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
          Row(
            children: [
              Material(
                color: accent.withValues(alpha: 0.18),
                shape: AppShape.superellipse(radius: AppSize.radiusSM),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: itemSemanticIconWidget(
                      iconKey: iconKey,
                      color: accent,
                      size: AppSize.icon,
                    ),
                  ),
                ),
              ),
              if (isDefault) ...[
                const Spacer(),
                Text(
                  l10n.itemDefaultBadge,
                  style: text.caption.copyWith(color: colors.onSurfaceMuted),
                ),
              ],
            ],
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
