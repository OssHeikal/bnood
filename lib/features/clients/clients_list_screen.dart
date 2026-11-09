import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/clients/clients_providers.dart';
import '../../core/providers/dashboard_providers.dart';
import '../../core/repositories/bnood_repository.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/shared/pagination/pagination.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_bottom_sheet.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../app/widgets/shell_nav_icon.dart';
import '../home/home_foundation_scope.dart';
import '../vouchers/inline_create_routes.dart';
import 'clients_list_paging.dart';
import 'widgets/client_balance_card.dart';
import 'widgets/clients_list_filter_chips.dart';

class ClientsListScreen extends ConsumerStatefulWidget {
  const ClientsListScreen({super.key});

  @override
  ConsumerState<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends ConsumerState<ClientsListScreen> {
  late final AppPagingController<HomeClientBalanceRow> _pagingController;
  final _searchController = TextEditingController();
  final _collapsingHeaderKey = GlobalKey();
  var _collapsingHeaderHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _pagingController = AppPagingController<HomeClientBalanceRow>(
      fetchPage: ref.read(clientsListPageFetcherProvider),
      pageSize: clientsListPageSize,
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addClient(BuildContext context, WidgetRef ref) async {
    final createdId = await CustomBottomSheet.show<String?>(
      context: context,
      builder: (_) => const InlineCreateClientPage(padForSystemChrome: false),
      nestedNavigator: false,
      showDragHandle: false,
    );
    if (createdId != null) {
      refreshAfterClientMutation(ref, clientId: createdId);
    }
  }

  void _refreshPaging() => _pagingController.refresh();

  void _cacheCollapsingHeaderHeight() {
    final box = _collapsingHeaderKey.currentContext?.findRenderObject() as RenderBox?;
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
        showAdd: true,
      ),
      ClientListArchiveFilter.active => (
        title: l10n.homeNoActiveClientsTitle,
        description: l10n.homeNoActiveClientsDescription,
        showAdd: true,
      ),
    };
    return AppFallback.section(
      icon: Icons.people_outline,
      title: empty.title,
      description: empty.description,
      actions: [
        if (empty.showAdd)
          AppFallbackAction(
            label: l10n.addClient,
            onPressed: () => _addClient(context, ref),
            role: AppFallbackActionRole.tertiary,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final filter = ref.watch(clientsListFilterProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) => _cacheCollapsingHeaderHeight());

    ref.listen(clientsListFilterProvider, (previous, next) {
      if (previous != next) _refreshPaging();
    });
    ref.listen(clientsListSearchQueryProvider, (previous, next) {
      if (previous != next) _refreshPaging();
    });
    bindPagingListRefreshEpoch(ref, PagingListIds.clients, _refreshPaging);
    ref.listen(remoteClientsEnabledProvider, (previous, next) {
      if (previous != next) _refreshPaging();
    });

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          return Scaffold(
            backgroundColor: colors.canvas,
            body: AppPagedView<HomeClientBalanceRow>(
              controller: _pagingController,
              pullToRefresh: true,
              refreshEdgeOffset: MediaQuery.paddingOf(context).top + kToolbarHeight,
              sliverHeaders: [
                CustomSliverAppBar(
                  title: l10n.navClients,
                  actions: [
                    CustomAppBarAction(
                      key: const Key('clients_app_bar_add'),
                      tooltip: l10n.addClient,
                      tone: CustomAppBarActionTone.tint,
                      onPressed: () => _addClient(context, ref),
                      child: ShellNavIcon(
                        asset: Assets.icons.clientsAddOutline,
                        color: colors.primaryOnTint,
                        size: AppSize.icon,
                        semanticsLabel: l10n.addClient,
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
                          placeholder: l10n.clientsSearchHint,
                          onChanged: (value) {
                            ref.read(clientsListSearchQueryProvider.notifier).state = value;
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(AppSize.screenPadding, 0, AppSize.screenPadding, AppSize.spaceSM),
                        child: ClientsListFilterChips(),
                      ),
                    ],
                  ),
                ),
              ],
              builders: AppPagedBuilders(empty: (ctx) => _emptyFallback(ctx, filter)),
              itemPadding: (index) => EdgeInsets.fromLTRB(
                AppSize.screenPadding,
                index == 0 ? AppSize.spaceSM : 0,
                AppSize.screenPadding,
                0,
              ),
              itemBuilder: (context, row, index) {
                final remoteMoney = ref.watch(remoteClientsEnabledProvider);
                return ClientBalanceCard(
                  name: row.client.name,
                  meta: row.client.phone,
                  receivedPiastres: row.receivedPiastres,
                  spentPiastres: row.spentPiastres,
                  amountPiastres: row.remainingPiastres,
                  accentKey: clientAccentKeyFor(row.client.id),
                  localeCode: localeCode,
                  minorPerMajor: remoteMoney ? 1000 : 100,
                  onTap: () => context.push('/clients/${row.client.id}'),
                );
              },
              sliverFooters: [
                const SliverPadding(padding: EdgeInsets.only(bottom: AppSize.spaceMD)),
                _ScrollUnderClearance(reserve: _collapsingHeaderHeight),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Extra scroll range so the header under [CustomSliverAppBar] can leave the
/// viewport when the list itself is shorter than the screen.
class _ScrollUnderClearance extends StatelessWidget {
  const _ScrollUnderClearance({required this.reserve});

  final double reserve;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final raw = constraints.viewportMainAxisExtent + reserve - constraints.precedingScrollExtent;
        final height = raw > 0 ? raw : 0.0;
        if (height == 0) return const SliverToBoxAdapter(child: SizedBox.shrink());
        return SliverToBoxAdapter(child: SizedBox(height: height));
      },
    );
  }
}
