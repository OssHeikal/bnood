import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/clients/data/client_statement_record.dart';
import 'package:bnood/features/clients/data/clients_providers.dart';
import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/ui/layout/app_layout.dart';
import '../../../../core/shared/pagination/pagination.dart';
import '../../../../core/network/api/api_error_user_message.dart';
import '../../../../core/ui/widgets/app_card.dart';
import '../../../../core/ui/widgets/app_fallback.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/features/clients/presentation/providers/client_detail_provider.dart';
import 'package:bnood/features/clients/presentation/models/client_detail_snapshot.dart';
import 'package:bnood/features/clients/presentation/models/client_movements_filters.dart';
import 'package:bnood/features/clients/presentation/providers/client_movements_paging.dart';
import 'package:bnood/features/clients/presentation/widgets/client_movements_filter_bar.dart';
import 'package:bnood/features/clients/presentation/widgets/client_movements_filter_sheets.dart';
import 'package:bnood/features/clients/presentation/widgets/interactive_movement_card.dart';
import '../../../../core/account/account_office_providers.dart';

class MovementsListScreen extends ConsumerWidget {
  const MovementsListScreen({super.key, required this.clientId, this.itemId});

  final String clientId;
  final String? itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _RemoteMovementsList(clientId: clientId, initialItemId: itemId);
  }
}

class _RemoteMovementsList extends ConsumerStatefulWidget {
  const _RemoteMovementsList({required this.clientId, this.initialItemId});

  final String clientId;
  final String? initialItemId;

  @override
  ConsumerState<_RemoteMovementsList> createState() =>
      _RemoteMovementsListState();
}

class _RemoteMovementsListState extends ConsumerState<_RemoteMovementsList> {
  late ClientMovementsFilters _filters;
  late AppPagingController<ClientDetailMovementLine> _pagingController;
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  List<AppClientStatementItemSpend> _itemOptions = const [];

  ClientMovementsQuery get _query =>
      ClientMovementsQuery(clientId: widget.clientId, filters: _filters);

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
      final spend = await ref
          .read(clientsRepositoryProvider)
          .getClientItemSpend(widget.clientId);
      if (!mounted) return;
      setState(() => _itemOptions = spend.items);
      if (widget.initialItemId != null) {
        final match = spend.items
            .where((i) => i.id == widget.initialItemId)
            .firstOrNull;
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
    final picked = await showMovementsSortSheet(
      context,
      current: _filters.sort,
    );
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
    final picked = await showMovementsItemSheet(
      context,
      items: _itemOptions,
      currentItemId: _filters.itemId,
    );
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
    final picked = await showMovementsDateSheet(
      context,
      from: _filters.from,
      to: _filters.to,
    );
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
    final voucherMutations =
        ref.watch(accountOfficeVoucherMutationsEnabledProvider);
    final showMoney = ref.watch(accountOfficeClientMoneyVisibleProvider);

    bindPagingListRefreshEpoch(
      ref,
      PagingListIds.clientMovements(widget.clientId),
      _refreshPaging,
    );
    final pagedBuilders = AppPagedBuilders<ClientDetailMovementLine>(
      firstPageError: (ctx, state, retry) => AppCard(
        child: AppFallback.section(
          icon: Icons.error_outline,
          title: l10n.clientMovementsLoadErrorTitle,
          description: screenErrorDescription(l10n, state.error),
          actions: [
            AppFallbackAction(
              label: l10n.retry,
              onPressed: retry,
              role: AppFallbackActionRole.tertiary,
            ),
          ],
        ),
      ),
      empty: (ctx) => AppCard(
        child: AppFallback.section(
          icon: Icons.receipt_long_outlined,
          title: l10n.clientDetailNoMovements,
        ),
      ),
    );

    final clientName = ref
        .watch(clientDetailProvider(widget.clientId))
        .valueOrNull
        ?.client
        .name;

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
                layout: context.isMobileLayout
                    ? AppPagedLayout.listSeparated
                    : AppPagedLayout.sliverTwoColumn,
                gridPadding: context.isMobileLayout
                    ? null
                    : EdgeInsets.fromLTRB(
                        context.pageGutter,
                        AppSize.spaceSM,
                        context.pageGutter,
                        0,
                      ),
                itemPadding: context.isMobileLayout
                    ? (_) => EdgeInsets.fromLTRB(
                        AppSize.screenPadding,
                        AppSize.spaceSM,
                        AppSize.screenPadding,
                        0,
                      )
                    : (_) => EdgeInsets.zero,
                builders: pagedBuilders,
                itemBuilder: (context, line, index) => InteractiveMovementCard(
                  line: line,
                  localeCode: localeCode,
                  mutationsEnabled: voucherMutations,
                  hideAmount: !showMoney,
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
