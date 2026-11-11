import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/floating_shell_dock.dart';
import '../../app/widgets/shell_nav_icon.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/providers_api/app_provider_record.dart';
import '../../core/providers_api/providers_riverpod.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/shared/pagination/pagination.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_bottom_sheet.dart';
import '../../core/widgets/custom_text_field.dart';
import '../home/home_foundation_scope.dart';
import 'provider_create_sheet.dart';
import 'provider_edit_sheet.dart';
import 'provider_mutation_actions.dart';
import 'providers_list_paging.dart';
import 'widgets/providers_filter_chips.dart';
import 'widgets/providers_list_tile.dart';
import 'widgets/providers_loading_skeleton.dart';

class ProvidersScreen extends ConsumerStatefulWidget {
  const ProvidersScreen({super.key});

  @override
  ConsumerState<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends ConsumerState<ProvidersScreen> {
  late final AppPagingController<AppProvider> _pagingController;
  final _searchController = TextEditingController();
  final _collapsingHeaderKey = GlobalKey();
  var _collapsingHeaderHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _pagingController = AppPagingController<AppProvider>(
      fetchPage: ref.read(providersListPagingProvider),
      pageSize: providersListPageSize,
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _refreshPaging() => _pagingController.refresh();

  Future<void> _addProvider(BuildContext context) {
    final filter = ref.read(providersListTypeFilterProvider);
    final initialType = switch (filter) {
      ProvidersListTypeFilter.craftsman => AppProviderType.craftsman,
      ProvidersListTypeFilter.supplier => AppProviderType.supplier,
      ProvidersListTypeFilter.all => AppProviderType.supplier,
    };
    return CustomBottomSheet.show<void>(
      context: context,
      builder: (_) => ProviderCreateSheet(initialType: initialType),
      nestedNavigator: false,
      showDragHandle: false,
    );
  }

  void _cacheCollapsingHeaderHeight() {
    final box = _collapsingHeaderKey.currentContext?.findRenderObject() as RenderBox?;
    if (!mounted || box == null || !box.hasSize) return;
    final height = box.size.height;
    if (height == _collapsingHeaderHeight) return;
    setState(() => _collapsingHeaderHeight = height);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(providersListTypeFilterProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) => _cacheCollapsingHeaderHeight());

    ref.listen(providersListTypeFilterProvider, (previous, next) {
      if (previous != next) _refreshPaging();
    });
    ref.listen(providersListSearchQueryProvider, (previous, next) {
      if (previous != next) _refreshPaging();
    });
    bindPagingListRefreshEpoch(ref, PagingListIds.providers, _refreshPaging);
    ref.listen(remoteProvidersEnabledProvider, (previous, next) {
      if (previous != next) _refreshPaging();
    });

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          return Scaffold(
            backgroundColor: colors.canvas,
            body: AppPagedView<AppProvider>(
              controller: _pagingController,
              pullToRefresh: true,
              refreshEdgeOffset: MediaQuery.paddingOf(context).top + kToolbarHeight,
              sliverHeaders: [
                CustomSliverAppBar(
                  title: l10n.directoryTitle,
                  actions: [
                    CustomAppBarAction(
                      key: const Key('providers_app_bar_add'),
                      tooltip: l10n.directoryAddProvider,
                      tone: CustomAppBarActionTone.tint,
                      onPressed: () => _addProvider(context),
                      child: ShellNavIcon(
                        asset: Assets.icons.addOutline,
                        color: colors.primaryOnTint,
                        size: AppSize.icon,
                        semanticsLabel: l10n.directoryAddProvider,
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    key: _collapsingHeaderKey,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSize.screenPadding,
                          0,
                          AppSize.screenPadding,
                          AppSize.spaceSM,
                        ),
                        child: CustomTextField.search(
                          controller: _searchController,
                          placeholder: l10n.providersSearchHint,
                          onChanged: (value) {
                            ref.read(providersListSearchQueryProvider.notifier).state = value;
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(AppSize.screenPadding, 0, AppSize.screenPadding, AppSize.spaceSM),
                        child: ProvidersListFilterChips(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSize.screenPadding,
                          0,
                          AppSize.screenPadding,
                          AppSize.spaceMD,
                        ),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            l10n.providersOnlineCaption,
                            style: context.text.caption.copyWith(color: colors.onSurfaceMuted),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              builders: AppPagedBuilders(
                firstPageProgress: (_, _) => const ProvidersLoadingSkeleton(),
                empty: (ctx) => AppFallback.section(
                  leading: ShellNavIcon(
                    asset: Assets.icons.directoryOutline,
                    color: ctx.colors.muted,
                    size: AppSize.icon,
                  ),
                  title: _emptyTitle(l10n, filter),
                  description: l10n.providersEmptyDescription,
                  actions: [
                    AppFallbackAction(
                      label: l10n.directoryAddProvider,
                      onPressed: () => _addProvider(ctx),
                      role: AppFallbackActionRole.primary,
                    ),
                  ],
                ),
              ),
              itemPadding: (index) => EdgeInsets.fromLTRB(
                AppSize.screenPadding,
                index == 0 ? AppSize.spaceXS : 0,
                AppSize.screenPadding,
                0,
              ),
              itemBuilder: (context, provider, index) {
                return ProvidersListTile(
                  key: ValueKey(provider.id),
                  provider: provider,
                  onOpenDetail: () => context.push('/providers/${provider.id}'),
                  onEdit: () => showProviderEditSheet(context, provider: provider),
                  onDelete: () => confirmDeleteProvider(context, ref, providerId: provider.id, name: provider.name),
                );
              },
              sliverFooters: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    bottom:
                        FloatingShellDock.clearanceHeight + MediaQuery.viewPaddingOf(context).bottom + AppSize.spaceLG,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _emptyTitle(AppLocalizations l10n, ProvidersListTypeFilter filter) {
    return switch (filter) {
      ProvidersListTypeFilter.supplier => l10n.providersEmptySuppliersTitle,
      ProvidersListTypeFilter.craftsman => l10n.providersEmptyCraftsmenTitle,
      ProvidersListTypeFilter.all => l10n.providersEmptyAllTitle,
    };
  }
}
