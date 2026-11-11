import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clients/client_statement_record.dart';
import '../../core/clients/clients_providers.dart';
import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/database/database.dart';
import '../../core/providers/app_providers.dart';
import '../../core/repositories/bnood_repository.dart';
import '../../core/shared/pagination/pagination.dart';
import '../../core/vouchers/vouchers_riverpod.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../home/home_foundation_scope.dart';
import 'client_detail_provider.dart';
import 'client_detail_snapshot.dart';
import 'client_movement_lines.dart';
import 'client_movements_filters.dart';
import 'client_movements_local_filter.dart';
import 'client_movements_paging.dart';
import 'widgets/client_movements_filter_bar.dart';
import 'widgets/client_movements_filter_sheets.dart';
import 'widgets/interactive_movement_card.dart';

class MovementsListScreen extends ConsumerWidget {
  const MovementsListScreen({super.key, required this.clientId, this.itemId});

  final String clientId;
  final String? itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(remoteVouchersEnabledProvider);
    if (remote) {
      return _RemoteMovementsList(clientId: clientId, initialItemId: itemId);
    }
    return _LocalMovementsList(clientId: clientId, initialItemId: itemId);
  }
}

class _RemoteMovementsList extends ConsumerStatefulWidget {
  const _RemoteMovementsList({required this.clientId, this.initialItemId});

  final String clientId;
  final String? initialItemId;

  @override
  ConsumerState<_RemoteMovementsList> createState() => _RemoteMovementsListState();
}

class _RemoteMovementsListState extends ConsumerState<_RemoteMovementsList> {
  late ClientMovementsFilters _filters;
  late AppPagingController<ClientDetailMovementLine> _pagingController;
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  List<AppClientStatementItemSpend> _itemOptions = const [];

  ClientMovementsQuery get _query => ClientMovementsQuery(clientId: widget.clientId, filters: _filters);

  @override
  void initState() {
    super.initState();
    _filters = ClientMovementsFilters(itemId: widget.initialItemId);
    _initPaging();
    _searchController.addListener(_onSearchTextChanged);
    _loadItemOptions();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  void _initPaging() {
    _pagingController = AppPagingController<ClientDetailMovementLine>(
      fetchPage: ref.read(clientMovementsPageFetcherProvider(_query)),
      pageSize: clientMovementsPageSize,
    );
  }

  void _rebuildPaging() {
    _pagingController.dispose();
    _initPaging();
  }

  void _onSearchTextChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final q = _searchController.text;
      if (q == _filters.searchQuery) return;
      setState(() {
        _filters = ClientMovementsFilters(
          searchQuery: q,
          itemId: _filters.itemId,
          itemName: _filters.itemName,
          sort: _filters.sort,
          from: _filters.from,
          to: _filters.to,
        );
        _rebuildPaging();
      });
    });
  }

  Future<void> _loadItemOptions() async {
    try {
      final spend = await ref.read(clientsRepositoryProvider).getClientItemSpend(widget.clientId);
      if (!mounted) return;
      setState(() => _itemOptions = spend.items);
      if (widget.initialItemId != null) {
        final match = spend.items.where((i) => i.id == widget.initialItemId).firstOrNull;
        if (match != null) {
          setState(
            () => _filters = ClientMovementsFilters(
              searchQuery: _filters.searchQuery,
              itemId: match.id,
              itemName: match.name,
              sort: _filters.sort,
              from: _filters.from,
              to: _filters.to,
            ),
          );
        }
      }
    } catch (_) {
      // Item sheet falls back to empty list until retry.
    }
  }

  void _setFilters(ClientMovementsFilters next) {
    if (next.searchQuery != _searchController.text) {
      _searchController.text = next.searchQuery;
    }
    setState(() {
      _filters = next;
      _rebuildPaging();
    });
  }

  void _clearAll() {
    _searchController.clear();
    _setFilters(const ClientMovementsFilters());
  }

  Future<void> _openSort() async {
    final picked = await showMovementsSortSheet(context, current: _filters.sort);
    if (picked == null || !mounted) return;
    _setFilters(
      ClientMovementsFilters(
        searchQuery: _filters.searchQuery,
        itemId: _filters.itemId,
        itemName: _filters.itemName,
        sort: picked,
        from: _filters.from,
        to: _filters.to,
      ),
    );
  }

  Future<void> _openItem() async {
    if (_itemOptions.isEmpty) await _loadItemOptions();
    if (!mounted) return;
    final picked = await showMovementsItemSheet(context, items: _itemOptions, currentItemId: _filters.itemId);
    if (picked == null || !mounted) return;
    _setFilters(
      ClientMovementsFilters(
        searchQuery: _filters.searchQuery,
        itemId: picked.itemId,
        itemName: picked.itemName,
        sort: _filters.sort,
        from: _filters.from,
        to: _filters.to,
      ),
    );
  }

  Future<void> _openDate() async {
    final picked = await showMovementsDateSheet(context, from: _filters.from, to: _filters.to);
    if (picked == null || !mounted) return;
    _setFilters(
      ClientMovementsFilters(
        searchQuery: _filters.searchQuery,
        itemId: _filters.itemId,
        itemName: _filters.itemName,
        sort: _filters.sort,
        from: picked.from,
        to: picked.to,
      ),
    );
  }

  void _refreshPaging() => _pagingController.refresh();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    bindPagingListRefreshEpoch(ref, PagingListIds.clientMovements(widget.clientId), _refreshPaging);
    ref.listen(remoteVouchersEnabledProvider, (previous, next) {
      if (previous != next) _refreshPaging();
    });

    final pagedBuilders = AppPagedBuilders<ClientDetailMovementLine>(
      firstPageError: (ctx, state, retry) => AppCard(
        child: AppFallback.section(
          icon: Icons.error_outline,
          title: l10n.clientMovementsLoadErrorTitle,
          description: state.error?.toString() ?? l10n.clientMovementsLoadErrorTitle,
          actions: [AppFallbackAction(label: l10n.retry, onPressed: retry, role: AppFallbackActionRole.tertiary)],
        ),
      ),
      empty: (ctx) => AppCard(
        child: AppFallback.section(icon: Icons.receipt_long_outlined, title: l10n.clientDetailNoMovements),
      ),
    );

    final clientName = ref.watch(clientDetailProvider(widget.clientId)).valueOrNull?.client.name;

    return HomeFoundationScope(
      child: Scaffold(
        appBar: CustomAppBar(title: l10n.movements, subtitle: clientName),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSize.screenPadding,
                AppSize.spaceSM,
                AppSize.screenPadding,
                AppSize.spaceSM,
              ),
              child: ClientMovementsFilterBar(
                searchController: _searchController,
                filters: _filters,
                onOpenSort: _openSort,
                onOpenItem: _openItem,
                onOpenDate: _openDate,
                onClearAll: _clearAll,
                onClearSort: () => _setFilters(
                  ClientMovementsFilters(
                    searchQuery: _filters.searchQuery,
                    itemId: _filters.itemId,
                    itemName: _filters.itemName,
                    from: _filters.from,
                    to: _filters.to,
                  ),
                ),
                onClearItem: () => _setFilters(
                  ClientMovementsFilters(
                    searchQuery: _filters.searchQuery,
                    sort: _filters.sort,
                    from: _filters.from,
                    to: _filters.to,
                  ),
                ),
                onClearDate: () => _setFilters(
                  ClientMovementsFilters(
                    searchQuery: _filters.searchQuery,
                    itemId: _filters.itemId,
                    itemName: _filters.itemName,
                    sort: _filters.sort,
                  ),
                ),
              ),
            ),
            Expanded(
              child: AppPagedView<ClientDetailMovementLine>(
                controller: _pagingController,
                pullToRefresh: true,
                layout: AppPagedLayout.listSeparated,
                builders: pagedBuilders,
                itemPadding: (_) =>
                    EdgeInsets.fromLTRB(AppSize.screenPadding, AppSize.spaceSM, AppSize.screenPadding, 0),
                itemBuilder: (context, line, index) => InteractiveMovementCard(
                  line: line,
                  localeCode: localeCode,
                  mutationsEnabled: true,
                  ledgerClientId: widget.clientId,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalMovementsList extends ConsumerStatefulWidget {
  const _LocalMovementsList({required this.clientId, this.initialItemId});

  final String clientId;
  final String? initialItemId;

  @override
  ConsumerState<_LocalMovementsList> createState() => _LocalMovementsListState();
}

class _LocalMovementsListState extends ConsumerState<_LocalMovementsList> {
  late ClientMovementsFilters _filters;
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  List<(String id, String name)> _localItems = const [];
  var _resolvedRouteItem = false;

  @override
  void initState() {
    super.initState();
    _filters = ClientMovementsFilters(itemId: widget.initialItemId);
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _filters = ClientMovementsFilters(
          searchQuery: _searchController.text,
          itemId: _filters.itemId,
          itemName: _filters.itemName,
          sort: _filters.sort,
          from: _filters.from,
          to: _filters.to,
        );
      });
    });
  }

  void _setFilters(ClientMovementsFilters next) {
    if (next.searchQuery != _searchController.text) {
      _searchController.text = next.searchQuery;
    }
    setState(() => _filters = next);
  }

  Future<List<AppClientStatementItemSpend>> _itemsForSheet() async {
    return _localItems
        .map(
          (e) => AppClientStatementItemSpend(
            id: e.$1,
            name: e.$2,
            spentMinor: 0,
            materialsMinor: 0,
            laborMinor: 0,
            colorKey: 'teal',
            iconKey: 'category',
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final repo = ref.watch(repositoryProvider);
    final clientName = ref.watch(clientDetailProvider(widget.clientId)).valueOrNull?.client.name;

    return HomeFoundationScope(
      child: FutureBuilder<Project?>(
        future: repo.primaryActiveProject(widget.clientId),
        builder: (context, projectSnap) {
          if (projectSnap.connectionState != ConnectionState.done) {
            return _MovementsShell(
              title: l10n.movements,
              subtitle: clientName,
              header: const SizedBox.shrink(),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          final project = projectSnap.data;
          if (project == null) {
            return _MovementsShell(
              title: l10n.movements,
              header: const SizedBox.shrink(),
              body: ListView(
                padding: const EdgeInsets.all(AppSize.screenPadding),
                children: [
                  AppCard(
                    child: AppFallback.section(icon: Icons.receipt_long_outlined, title: l10n.clientDetailNoMovements),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder<MovementEntityMaps>(
            future: _loadEntityMaps(repo),
            builder: (context, mapsSnap) {
              if (mapsSnap.connectionState != ConnectionState.done) {
                return _MovementsShell(
                  title: l10n.movements,
                  header: const SizedBox.shrink(),
                  body: const Center(child: CircularProgressIndicator()),
                );
              }
              if (mapsSnap.hasError) {
                return _MovementsShell(
                  title: l10n.movements,
                  header: const SizedBox.shrink(),
                  body: ListView(
                    padding: const EdgeInsets.all(AppSize.screenPadding),
                    children: [
                      AppCard(
                        child: AppFallback.section(
                          icon: Icons.error_outline,
                          title: l10n.clientMovementsLoadErrorTitle,
                          description: mapsSnap.error.toString(),
                        ),
                      ),
                    ],
                  ),
                );
              }
              final maps = mapsSnap.data;
              if (maps == null) {
                return _MovementsShell(
                  title: l10n.movements,
                  header: const SizedBox.shrink(),
                  body: const Center(child: CircularProgressIndicator()),
                );
              }

              _localItems = maps.itemById.entries.map((e) => (e.key, e.value.name)).toList();
              if (!_resolvedRouteItem && widget.initialItemId != null) {
                final match = maps.itemById[widget.initialItemId];
                if (match != null) {
                  _resolvedRouteItem = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(
                      () => _filters = ClientMovementsFilters(
                        searchQuery: _filters.searchQuery,
                        itemId: widget.initialItemId,
                        itemName: match.name,
                        sort: _filters.sort,
                        from: _filters.from,
                        to: _filters.to,
                      ),
                    );
                  });
                }
              }

              final header = ClientMovementsFilterBar(
                searchController: _searchController,
                filters: _filters,
                onOpenSort: () async {
                  final picked = await showMovementsSortSheet(context, current: _filters.sort);
                  if (picked == null || !context.mounted) return;
                  _setFilters(
                    ClientMovementsFilters(
                      searchQuery: _filters.searchQuery,
                      itemId: _filters.itemId,
                      itemName: _filters.itemName,
                      sort: picked,
                      from: _filters.from,
                      to: _filters.to,
                    ),
                  );
                },
                onOpenItem: () async {
                  final picked = await showMovementsItemSheet(
                    context,
                    items: await _itemsForSheet(),
                    currentItemId: _filters.itemId,
                  );
                  if (picked == null || !context.mounted) return;
                  _setFilters(
                    ClientMovementsFilters(
                      searchQuery: _filters.searchQuery,
                      itemId: picked.itemId,
                      itemName: picked.itemName,
                      sort: _filters.sort,
                      from: _filters.from,
                      to: _filters.to,
                    ),
                  );
                },
                onOpenDate: () async {
                  final picked = await showMovementsDateSheet(context, from: _filters.from, to: _filters.to);
                  if (picked == null || !context.mounted) return;
                  _setFilters(
                    ClientMovementsFilters(
                      searchQuery: _filters.searchQuery,
                      itemId: _filters.itemId,
                      itemName: _filters.itemName,
                      sort: _filters.sort,
                      from: picked.from,
                      to: picked.to,
                    ),
                  );
                },
                onClearAll: () {
                  _searchController.clear();
                  _setFilters(const ClientMovementsFilters());
                },
                onClearSort: () => _setFilters(
                  ClientMovementsFilters(
                    searchQuery: _filters.searchQuery,
                    itemId: _filters.itemId,
                    itemName: _filters.itemName,
                    from: _filters.from,
                    to: _filters.to,
                  ),
                ),
                onClearItem: () => _setFilters(
                  ClientMovementsFilters(
                    searchQuery: _filters.searchQuery,
                    sort: _filters.sort,
                    from: _filters.from,
                    to: _filters.to,
                  ),
                ),
                onClearDate: () => _setFilters(
                  ClientMovementsFilters(
                    searchQuery: _filters.searchQuery,
                    itemId: _filters.itemId,
                    itemName: _filters.itemName,
                    sort: _filters.sort,
                  ),
                ),
              );

              return _MovementsShell(
                title: l10n.movements,
                header: header,
                body: StreamBuilder<List<Transaction>>(
                  stream: repo.watchProjectTransactions(project.id),
                  builder: (context, snap) {
                    final tx = snap.data ?? [];
                    final lines = filterLocalMovementLines(
                      transactions: tx,
                      filters: _filters,
                      itemById: maps.itemById,
                      supplierById: maps.supplierById,
                      craftsmanById: maps.craftsmanById,
                    );

                    if (lines.isEmpty) {
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSize.screenPadding,
                          AppSize.spaceSM,
                          AppSize.screenPadding,
                          AppSize.spaceMD,
                        ),
                        children: [
                          AppCard(
                            child: AppFallback.section(
                              icon: Icons.receipt_long_outlined,
                              title: l10n.clientDetailNoMovements,
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        AppSize.screenPadding,
                        AppSize.spaceSM,
                        AppSize.screenPadding,
                        AppSize.spaceMD + MediaQuery.paddingOf(context).bottom,
                      ),
                      itemCount: lines.length,
                      separatorBuilder: (_, _) => AppSize.spaceMD.gap,
                      itemBuilder: (context, index) =>
                          InteractiveMovementCard(line: lines[index], localeCode: localeCode, mutationsEnabled: true),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<MovementEntityMaps> _loadEntityMaps(BnoodRepository repo) async {
    final items = await repo.watchActiveItems().first;
    final suppliers = await repo.watchActiveSuppliers().first;
    final craftsmen = await repo.watchActiveCraftsmen().first;
    return (
      itemById: {for (final i in items) i.id: i},
      supplierById: {for (final s in suppliers) s.id: s},
      craftsmanById: {for (final c in craftsmen) c.id: c},
    );
  }
}

class _MovementsShell extends StatelessWidget {
  const _MovementsShell({
    required this.title,
    required this.header,
    required this.body,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget header;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: CustomAppBar(title: title, subtitle: subtitle),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSize.screenPadding,
              AppSize.spaceSM,
              AppSize.screenPadding,
              AppSize.spaceSM,
            ),
            child: header,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
