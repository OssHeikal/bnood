import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/config/theme/app_size.dart';
import '../../../core/items/item_api_record.dart';
import '../../../core/layout/bnood_grid_count.dart';
import 'item_catalog_tile.dart';

/// Two-column catalog grid with long-press drag reorder for every item (defaults included).
class ItemsReorderableUserGrid extends StatelessWidget {
  const ItemsReorderableUserGrid({
    super.key,
    required this.items,
    required this.onReorder,
    required this.onOpenEdit,
  });

  final List<CatalogItem> items;
  final Future<void> Function(int oldIndex, int newIndex) onReorder;
  final void Function(CatalogItem item) onOpenEdit;

  static const _mainAxisExtent = 116.0;

  SliverGridDelegate _gridDelegate(BuildContext context) {
    final crossAxisCount = bnoodGridCount(context, mobile: 2, tablet: 3, desktop: 4);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: AppSize.spaceMD,
      mainAxisSpacing: AppSize.spaceMD,
      mainAxisExtent: _mainAxisExtent,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = bnoodGridCount(context, mobile: 2, tablet: 3, desktop: 4);
        final cellWidth =
            (constraints.maxWidth - AppSize.spaceMD * (crossAxisCount - 1)) / crossAxisCount;
        final gridDelegate = _gridDelegate(context);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: gridDelegate,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final openEdit = item.isDefault ? null : () => onOpenEdit(item);
            return DragTarget<int>(
              onWillAcceptWithDetails: (details) => details.data != index,
              onAcceptWithDetails: (details) => onReorder(details.data, index),
              builder: (context, candidate, rejected) {
                return LongPressDraggable<int>(
                  data: index,
                  onDragStarted: () => HapticFeedback.lightImpact(),
                  feedback: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: cellWidth,
                      height: _mainAxisExtent,
                      child: ItemCatalogTile(
                        name: item.name,
                        colorKey: item.colorKey,
                        iconKey: item.iconKey,
                        isDefault: item.isDefault,
                        onOpenEdit: openEdit,
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.35,
                    child: ItemCatalogTile(
                      name: item.name,
                      colorKey: item.colorKey,
                      iconKey: item.iconKey,
                      isDefault: item.isDefault,
                      onOpenEdit: openEdit,
                    ),
                  ),
                  child: ItemCatalogTile(
                    key: ValueKey(item.id),
                    name: item.name,
                    colorKey: item.colorKey,
                    iconKey: item.iconKey,
                    isDefault: item.isDefault,
                    onOpenEdit: openEdit,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
