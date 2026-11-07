import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/floating_shell_dock.dart';
import '../../app/widgets/shell_nav_icon.dart';
import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_shape.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/database/database.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/widgets/app_pressable.dart';
import '../../core/widgets/custom_bottom_sheet.dart';
import '../../core/widgets/foundation_app_bar_title.dart';
import '../../core/widgets/skeleton/async_value_body.dart';
import '../home/home_foundation_scope.dart';
import 'item_create_sheet.dart';
import 'item_edit_sheet.dart';
import 'items_catalog_provider.dart';
import 'widgets/item_catalog_tile.dart';
import 'widgets/items_loading_skeleton.dart';

class ItemsScreen extends ConsumerWidget {
  const ItemsScreen({super.key});

  Future<void> _addItem(BuildContext context) {
    return CustomBottomSheet.show<void>(
      context: context,
      builder: (_) => const ItemCreateSheet(),
      nestedNavigator: false,
      showDragHandle: false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(itemsCatalogProvider);

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final text = context.text;
          return Scaffold(
            backgroundColor: colors.canvas,
            appBar: AppBar(
              backgroundColor: colors.canvas,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              elevation: 0,
              centerTitle: false,
              title: FoundationAppBarTitle(title: l10n.navItems),
              actions: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppSize.spaceMD),
                  child: Tooltip(
                    message: l10n.addItem,
                    child: AppPressable(
                      onPressed: () => _addItem(context),
                      child: Material(
                        key: const Key('items_app_bar_add'),
                        color: colors.accentTeal.tint,
                        shape: AppShape.superellipse(radius: AppSize.radiusSM),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          width: AppSize.buttonHeight,
                          height: AppSize.buttonHeight,
                          child: Center(
                            child: ShellNavIcon(
                              asset: Assets.icons.itemsAddOutline,
                              color: colors.primaryOnTint,
                              size: AppSize.icon,
                              semanticsLabel: l10n.addItem,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSize.screenPadding,
                AppSize.spaceSM,
                AppSize.screenPadding,
                AppSize.spaceMD,
              ),
              children: [
                Text(
                  l10n.itemsCatalogCaption,
                  style: text.caption.copyWith(color: colors.onSurfaceMuted),
                ),
                AppSize.spaceMD.gap,
                AsyncValueBody(
                  value: catalog,
                  loadingPlaceholder: const ItemsLoadingSkeleton(),
                  error: (e, _) => AppCard(
                    child: AppFallback.section(
                      icon: Icons.error_outline,
                      title: l10n.homeLoadErrorTitle,
                      description: e.toString(),
                      actions: [
                        AppFallbackAction(
                          label: l10n.retry,
                          onPressed: () => ref.invalidate(itemsCatalogProvider),
                          role: AppFallbackActionRole.tertiary,
                        ),
                      ],
                    ),
                  ),
                  data: (items) => _ItemsCatalogGrid(
                    items: items,
                    onAdd: () => _addItem(context),
                    onOpenEdit: (item) => showItemEditSheet(
                      context,
                      itemId: item.id,
                      name: item.name,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ItemsCatalogGrid extends StatelessWidget {
  const _ItemsCatalogGrid({
    required this.items,
    required this.onAdd,
    required this.onOpenEdit,
  });

  final List<Item> items;
  final VoidCallback onAdd;
  final void Function(Item item) onOpenEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      return AppCard(
        child: AppFallback.section(
          leading: ShellNavIcon(
            asset: Assets.icons.itemsLayersOutline,
            color: context.colors.muted,
            size: AppSize.icon,
          ),
          title: l10n.itemsEmptyTitle,
          description: l10n.itemsEmptyDescription,
          actions: [
            AppFallbackAction(
              label: l10n.addItem,
              onPressed: onAdd,
              role: AppFallbackActionRole.primary,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      key: const Key('items_catalog_grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSize.spaceMD,
        mainAxisSpacing: AppSize.spaceMD,
        mainAxisExtent: 116,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ItemCatalogTile(
          key: ValueKey(item.id),
          name: item.name,
          colorKey: item.colorKey,
          iconName: item.iconName,
          onOpenEdit: () => onOpenEdit(item),
        );
      },
    );
  }
}

/// Scroll clearance matching [ShellScaffold] dock fade for tests without the shell.
EdgeInsets itemsScreenMediaQueryForTests(BuildContext context) {
  final base = MediaQuery.paddingOf(context);
  return base.copyWith(
    bottom: base.bottom + FloatingShellDock.clearanceHeight,
  );
}
