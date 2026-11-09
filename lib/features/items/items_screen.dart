import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/floating_shell_dock.dart';
import '../../app/widgets/shell_nav_icon.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/items/item_api_record.dart';
import '../../core/items/items_providers.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/shared/pagination/pagination.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/widgets/custom_bottom_sheet.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../home/home_foundation_scope.dart';
import 'item_create_sheet.dart';
import 'item_edit_sheet.dart';
import 'items_list_paging.dart';
import 'widgets/item_catalog_tile.dart';
import 'widgets/items_loading_skeleton.dart';

class ItemsScreen extends ConsumerStatefulWidget {
  const ItemsScreen({super.key});

  @override
  ConsumerState<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends ConsumerState<ItemsScreen> {
  late final AppPagingController<CatalogItem> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = AppPagingController<CatalogItem>(
      fetchPage: ref.read(itemsListPageFetcherProvider),
      pageSize: itemsListPageSize,
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _addItem(BuildContext context) {
    return CustomBottomSheet.show<void>(
      context: context,
      builder: (_) => const ItemCreateSheet(),
      nestedNavigator: false,
      showDragHandle: false,
    );
  }

  void _refreshPaging() => _pagingController.refresh();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    ref.listen(remoteItemsEnabledProvider, (previous, next) {
      if (previous != next) _refreshPaging();
    });
    bindPagingListRefreshEpoch(ref, PagingListIds.items, _refreshPaging);

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final text = context.text;
          return Scaffold(
            backgroundColor: colors.canvas,
            appBar: CustomAppBar(
              title: l10n.navItems,
              actions: [
                CustomAppBarAction(
                  key: const Key('items_app_bar_add'),
                  tooltip: l10n.addItem,
                  tone: CustomAppBarActionTone.tint,
                  onPressed: () => _addItem(context),
                  child: ShellNavIcon(
                    asset: Assets.icons.itemsAddOutline,
                    color: colors.primaryOnTint,
                    size: AppSize.icon,
                    semanticsLabel: l10n.addItem,
                  ),
                ),
              ],
            ),
            body: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: AppPagedView<CatalogItem>(
                controller: _pagingController,
                pullToRefresh: true,
                layout: AppPagedLayout.sliverGrid,
                gridPadding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
                builders: AppPagedBuilders<CatalogItem>(
                  firstPageProgress: (_, _) => const ItemsLoadingSkeleton(),
                  empty: (ctx) => AppCard(
                    child: AppFallback.section(
                      leading: ShellNavIcon(
                        asset: Assets.icons.itemsLayersOutline,
                        color: ctx.colors.muted,
                        size: AppSize.icon,
                      ),
                      title: l10n.itemsEmptyTitle,
                      description: l10n.itemsEmptyDescription,
                      actions: [
                        AppFallbackAction(
                          label: l10n.addItem,
                          onPressed: () => _addItem(ctx),
                          role: AppFallbackActionRole.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                sliverHeaders: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSize.screenPadding,
                        AppSize.spaceSM,
                        AppSize.screenPadding,
                        AppSize.spaceMD,
                      ),
                      child: Text(l10n.itemsCatalogCaption, style: text.caption.copyWith(color: colors.onSurfaceMuted)),
                    ),
                  ),
                ],
                sliverFooters: [
                  SliverPadding(
                    padding: EdgeInsets.only(
                      bottom:
                          FloatingShellDock.clearanceHeight +
                          MediaQuery.viewPaddingOf(context).bottom +
                          AppSize.spaceLG,
                    ),
                  ),
                ],
                itemBuilder: (context, item, index) {
                  return ItemCatalogTile(
                    key: ValueKey(item.id),
                    name: item.name,
                    colorKey: item.colorKey,
                    iconKey: item.iconKey,
                    isDefault: item.isDefault,
                    onOpenEdit: item.isDefault ? null : () => showItemEditSheet(context, item: item),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Scroll clearance matching [ShellScaffold] dock fade for tests without the shell.
EdgeInsets itemsScreenMediaQueryForTests(BuildContext context) {
  final base = MediaQuery.paddingOf(context);
  return base.copyWith(bottom: base.bottom + FloatingShellDock.clearanceHeight);
}
