import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/ui/layout/app_layout.dart';
import '../../../../core/domain/money/remote_money_units.dart';
import 'package:bnood/features/clients/data/client_list_archive_filter.dart';
import 'package:bnood/core/account/account_context_providers.dart';
import '../../../../core/shared/pagination/pagination.dart';
import '../../../../core/ui/widgets/app_fallback.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import 'package:bnood/features/clients/presentation/widgets/client_balance_card.dart';
import '../../../../core/ui/widgets/directory_search_field.dart';
import '../../../../app/shell_tab_scaffold.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/features/clients/presentation/widgets/clients_list_filter_chips.dart';
import 'package:bnood/features/projects/data/project_list_row.dart';
import 'package:bnood/features/projects/presentation/providers/projects_list_paging.dart';
import 'package:bnood/features/projects/presentation/providers/projects_list_providers.dart';

class ProjectsListScreen extends ConsumerStatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  ConsumerState<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends ConsumerState<ProjectsListScreen> {
  late final AppPagingController<ProjectListRow> _pagingController;
  final _searchController = TextEditingController();
  final _collapsingHeaderKey = GlobalKey();
  var _collapsingHeaderHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _pagingController = AppPagingController<ProjectListRow>(
      fetchPage: ref.read(projectsListPageFetcherProvider),
      pageSize: projectsListPageSize,
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _refreshPaging() => _pagingController.refresh();

  void _cacheCollapsingHeaderHeight() {
    final box =
        _collapsingHeaderKey.currentContext?.findRenderObject() as RenderBox?;
    if (!mounted || box == null || !box.hasSize) return;
    final height = box.size.height;
    if (height == _collapsingHeaderHeight) return;
    setState(() => _collapsingHeaderHeight = height);
  }

  Widget _emptyFallback(BuildContext context, ClientListArchiveFilter filter) {
    final l10n = AppLocalizations.of(context);
    final empty = switch (filter) {
      ClientListArchiveFilter.archived => (
        title: l10n.clientsNoArchivedTitle,
        description: l10n.clientsNoArchivedDescription,
        showAdd: false,
      ),
      ClientListArchiveFilter.all => (
        title: l10n.clientsNoClientsTitle,
        description: l10n.homeNoActiveClientsDescription,
        showAdd: false,
      ),
      ClientListArchiveFilter.active => (
        title: l10n.homeNoActiveClientsTitle,
        description: l10n.homeNoActiveClientsDescription,
        showAdd: false,
      ),
    };
    return AppFallback.section(
      icon: Icons.folder_open_outlined,
      title: empty.title,
      description: empty.description,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final filter = ref.watch(projectsListFilterProvider);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _cacheCollapsingHeaderHeight(),
    );

    ref.listen(projectsListFilterProvider, (previous, next) {
      if (previous != next) _refreshPaging();
    });
    ref.listen(projectsListSearchQueryProvider, (previous, next) {
      if (previous != next) _refreshPaging();
    });
    ref.listen(accountContextProvider, (previous, next) {
      if (previous?.isPersonal != next.isPersonal ||
          previous?.officeId != next.officeId) {
        _refreshPaging();
      }
    });
    bindPagingListRefreshEpoch(ref, PagingListIds.clients, _refreshPaging);
    bindPagingListRefreshEpoch(ref, PagingListIds.projects, _refreshPaging);

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final gutter = context.pageGutter;
          final useGrid = !context.isMobileLayout;
          return ShellTabScaffold(
            backgroundColor: colors.canvas,
            body: AppPagedView<ProjectListRow>(
              controller: _pagingController,
              layout: useGrid
                  ? AppPagedLayout.sliverTwoColumn
                  : AppPagedLayout.sliverListSeparated,
              pullToRefresh: true,
              refreshEdgeOffset:
                  MediaQuery.paddingOf(context).top + kToolbarHeight,
              sliverHeaders: [
                CustomSliverAppBar(
                  title: l10n.navProjects,
                  automaticallyImplyLeading: false,
                ),
                SliverToBoxAdapter(
                  child: Column(
                    key: _collapsingHeaderKey,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          gutter,
                          0,
                          gutter,
                          AppSize.spaceSM,
                        ),
                        child: DirectorySearchField(
                          controller: _searchController,
                          placeholder: l10n.clientsSearchHint,
                          onChanged: (value) {
                            ref
                                    .read(
                                      projectsListSearchQueryProvider.notifier,
                                    )
                                    .state =
                                value;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          gutter,
                          0,
                          gutter,
                          AppSize.spaceSM,
                        ),
                        child: ClientsListFilterChips(
                          filterProvider: projectsListFilterProvider,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              builders: AppPagedBuilders(
                errorTitle: l10n.clientsLoadErrorTitle,
                empty: (ctx) => _emptyFallback(ctx, filter),
              ),
              itemPadding: (index) => useGrid
                  ? EdgeInsets.zero
                  : EdgeInsets.fromLTRB(
                      gutter,
                      index == 0 ? AppSize.spaceSM : 0,
                      gutter,
                      0,
                    ),
              gridPadding: useGrid
                  ? EdgeInsets.fromLTRB(gutter, AppSize.spaceSM, gutter, 0)
                  : null,
              itemBuilder: (context, row, index) {
                return ClientBalanceCard(
                  name: row.projectName,
                  meta: row.clientName,
                  receivedPiastres: row.receivedPiastres,
                  spentPiastres: row.spentPiastres,
                  amountPiastres: row.remainingPiastres,
                  accentKey: clientAccentKeyFor(row.clientId),
                  localeCode: localeCode,
                  minorPerMajor: RemoteMoneyUnits.minorPerMajor,
                  onTap: () => context.push(
                    '/projects/${row.projectId}?clientId=${row.clientId}',
                  ),
                );
              },
              sliverFooters: [
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: AppSize.spaceMD),
                ),
                _ScrollUnderClearance(reserve: _collapsingHeaderHeight),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ScrollUnderClearance extends StatelessWidget {
  const _ScrollUnderClearance({required this.reserve});

  final double reserve;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final raw =
            constraints.viewportMainAxisExtent +
            reserve -
            constraints.precedingScrollExtent;
        final height = raw > 0 ? raw : 0.0;
        if (height == 0) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverToBoxAdapter(child: SizedBox(height: height));
      },
    );
  }
}