import 'package:flutter/material.dart';

import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/skeleton/skeleton.dart';
import '../../../core/widgets/skeleton/skeleton_box.dart';
import '../../../core/widgets/skeleton/skeleton_text.dart';

/// Mirrors [ItemCatalogTile]: tinted card padding, icon chip row, title at bottom.
class ItemsLoadingSkeleton extends StatelessWidget {
  const ItemsLoadingSkeleton({super.key, this.count = 4});

  final int count;

  static const iconSize = 40.0;
  static const defaultBadgeWidth = 48.0;
  static const titlePrimaryWidth = 88.0;
  static const titleSecondaryWidth = 64.0;

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        // Null padding reapplies MediaQuery safe area and drops the grid by the status bar.
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSize.spaceMD,
          mainAxisSpacing: AppSize.spaceMD,
          mainAxisExtent: 116,
        ),
        itemCount: count,
        itemBuilder: (context, index) => const ItemCatalogTileSkeleton(),
      ),
    );
  }
}

/// Single grid cell matching [ItemCatalogTile] layout (icon + badge row, spacer, title).
class ItemCatalogTileSkeleton extends StatelessWidget {
  const ItemCatalogTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSize.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              SkeletonBox(
                width: ItemsLoadingSkeleton.iconSize,
                height: ItemsLoadingSkeleton.iconSize,
                radius: AppSize.radiusSM,
              ),
              Spacer(),
              SkeletonText(
                role: SkeletonTextRole.label,
                width: ItemsLoadingSkeleton.defaultBadgeWidth,
              ),
            ],
          ),
          const Spacer(),
          const SkeletonText(
            role: SkeletonTextRole.body,
            width: ItemsLoadingSkeleton.titlePrimaryWidth,
          ),
          const SizedBox(height: AppSize.spaceXS),
          const SkeletonText(
            role: SkeletonTextRole.body,
            width: ItemsLoadingSkeleton.titleSecondaryWidth,
          ),
        ],
      ),
    );
  }
}
