import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/shell_bottom_inset.dart';
import '../../app/shell_tab_scaffold.dart';
import '../../app/widgets/shell_nav_icon.dart';
import '../../core/api/api_error_user_message.dart';
import '../../core/api/auth_api_exception.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/layout/app_layout.dart';
import '../../core/layout/bnood_max_width.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/shared/pagination/paging_refresh.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/custom_bottom_sheet.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../home/home_foundation_scope.dart';
import 'item_create_sheet.dart';
import 'item_edit_sheet.dart';
import 'items_catalog_notifier.dart';
import 'widgets/items_loading_skeleton.dart';
import 'widgets/items_reorderable_user_grid.dart';

class ItemsScreen extends ConsumerStatefulWidget {
  const ItemsScreen({super.key});

  @override
  ConsumerState<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends ConsumerState<ItemsScreen> {
  void _refreshCatalog() => ref.read(itemsCatalogProvider.notifier).reload();

  Future<void> _addItem(BuildContext context) {
    return CustomBottomSheet.show<void>(
      context: context,
      builder: (_) => const ItemCreateSheet(),
      nestedNavigator: false,
      showDragHandle: false,
    );
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    try {
      await ref.read(itemsCatalogProvider.notifier).reorderCatalogItem(oldIndex: oldIndex, newIndex: newIndex);
    } on AuthApiException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      AppToaster.show(apiErrorUserMessage(l10n, e), kind: ToastKind.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(itemsCatalogProvider);

    bindPagingListRefreshEpoch(ref, PagingListIds.items, _refreshCatalog);

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final gutter = context.pageGutter;
          final bottomClearance = ShellBottomInset.listScrollBottomPadding(context);

          return ShellTabScaffold(
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
            body: BnoodMaxWidth(
              maxWidth: AppLayout.pageMaxWidth,
              child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: catalog.when(
                loading: () => CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _captionSliver(context, l10n),
                    const SliverPadding(
                      padding: EdgeInsets.zero,
                      sliver: SliverToBoxAdapter(child: ItemsLoadingSkeleton()),
                    ),
                    SliverPadding(padding: EdgeInsets.only(bottom: bottomClearance)),
                  ],
                ),
                error: (error, _) => CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _captionSliver(context, l10n),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: AppFallback.section(
                          icon: Icons.error_outline,
                          title: error.toString(),
                          actions: [
                            AppFallbackAction(
                              label: l10n.retry,
                              onPressed: _refreshCatalog,
                              role: AppFallbackActionRole.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            0,
                            AppSize.spaceSM,
                            0,
                            AppSize.spaceMD,
                          ),
                          child: Text(
                            l10n.itemsCatalogCaption,
                            style: context.text.caption.copyWith(color: colors.onSurfaceMuted),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(gutter, 0, gutter, bottomClearance),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  physics: const ClampingScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        AppEmptyState(
                                          key: const Key('items_empty_state'),
                                          leading: ShellNavIcon(
                                            asset: Assets.icons.itemsLayersOutline,
                                            color: colors.primary,
                                            size: AppSize.iconExtraLarge,
                                            semanticsLabel: l10n.navItems,
                                          ),
                                          title: l10n.itemsEmptyTitle,
                                          description: l10n.itemsEmptyDescription,
                                          primaryActionLabel: l10n.addItem,
                                          onPrimaryAction: () => _addItem(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return RefreshIndicator.adaptive(
                    onRefresh: () => ref.read(itemsCatalogProvider.notifier).reload(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        _captionSliver(context, l10n),
                        SliverPadding(
                          padding: EdgeInsets.zero,
                          sliver: SliverToBoxAdapter(
                            child: ItemsReorderableUserGrid(
                              items: items,
                              onReorder: _handleReorder,
                              onOpenEdit: (item) => showItemEditSheet(context, item: item),
                            ),
                          ),
                        ),
                        SliverPadding(padding: EdgeInsets.only(bottom: bottomClearance)),
                      ],
                    ),
                  );
                },
              ),
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _captionSliver(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    final text = context.text;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          0,
          AppSize.spaceSM,
          0,
          AppSize.spaceMD,
        ),
        child: Text(l10n.itemsCatalogCaption, style: text.caption.copyWith(color: colors.onSurfaceMuted)),
      ),
    );
  }
}

/// Scroll clearance matching [ShellScaffold] dock fade for tests without the shell.
EdgeInsets itemsScreenMediaQueryForTests(BuildContext context) {
  final base = MediaQuery.paddingOf(context);
  return base.copyWith(bottom: base.bottom + ShellBottomInset.mediaQueryDockClearance(context));
}
