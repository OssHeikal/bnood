import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import 'client_detail_snapshot.dart';
import 'client_movement_lines.dart';
import 'client_movements_paging.dart';
import 'widgets/interactive_movement_card.dart';

class MovementsListScreen extends ConsumerWidget {
  const MovementsListScreen({super.key, required this.clientId, this.itemId});

  final String clientId;
  final String? itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(remoteVouchersEnabledProvider);
    if (remote) {
      return _RemoteMovementsList(clientId: clientId, itemId: itemId);
    }
    return _LocalMovementsList(clientId: clientId);
  }
}

class _RemoteMovementsList extends ConsumerStatefulWidget {
  const _RemoteMovementsList({required this.clientId, this.itemId});

  final String clientId;
  final String? itemId;

  @override
  ConsumerState<_RemoteMovementsList> createState() => _RemoteMovementsListState();
}

class _RemoteMovementsListState extends ConsumerState<_RemoteMovementsList> {
  late final AppPagingController<ClientDetailMovementLine> _pagingController;

  ClientMovementsQuery get _query => ClientMovementsQuery(clientId: widget.clientId, itemId: widget.itemId);

  @override
  void initState() {
    super.initState();
    _pagingController = AppPagingController<ClientDetailMovementLine>(
      fetchPage: ref.read(clientMovementsPageFetcherProvider(_query)),
      pageSize: clientMovementsPageSize,
    );
  }

  @override
  void didUpdateWidget(covariant _RemoteMovementsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clientId != widget.clientId || oldWidget.itemId != widget.itemId) {
      _pagingController.dispose();
      _pagingController = AppPagingController<ClientDetailMovementLine>(
        fetchPage: ref.read(clientMovementsPageFetcherProvider(_query)),
        pageSize: clientMovementsPageSize,
      );
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
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

    return HomeFoundationScope(
      child: Scaffold(
        backgroundColor: context.colors.canvas,
        appBar: CustomAppBar(title: l10n.movements),
        body: AppPagedView<ClientDetailMovementLine>(
          controller: _pagingController,
          pullToRefresh: true,
          layout: AppPagedLayout.listSeparated,
          builders: AppPagedBuilders<ClientDetailMovementLine>(
            firstPageError: (ctx, state, retry) {
              return AppCard(
                child: AppFallback.section(
                  icon: Icons.error_outline,
                  title: l10n.clientMovementsLoadErrorTitle,
                  description: state.error?.toString() ?? l10n.clientMovementsLoadErrorTitle,
                  actions: [
                    AppFallbackAction(
                      label: l10n.retry,
                      onPressed: retry,
                      role: AppFallbackActionRole.tertiary,
                    ),
                  ],
                ),
              );
            },
            newPageError: (ctx, state, retry) {
              return AppCard(
                child: AppFallback.section(
                  icon: Icons.error_outline,
                  title: l10n.clientMovementsLoadErrorTitle,
                  description: state.error?.toString() ?? l10n.clientMovementsLoadErrorTitle,
                  actions: [
                    AppFallbackAction(
                      label: l10n.retry,
                      onPressed: retry,
                      role: AppFallbackActionRole.tertiary,
                    ),
                  ],
                ),
              );
            },
            empty: (ctx) {
              return AppCard(
                child: AppFallback.section(
                  icon: Icons.receipt_long_outlined,
                  title: l10n.clientDetailNoMovements,
                ),
              );
            },
          ),
          itemPadding: (_) => EdgeInsets.fromLTRB(
            AppSize.screenPadding,
            AppSize.spaceSM,
            AppSize.screenPadding,
            0,
          ),
          itemBuilder: (context, line, index) {
            return InteractiveMovementCard(
              line: line,
              localeCode: localeCode,
              mutationsEnabled: true,
              ledgerClientId: widget.clientId,
            );
          },
        ),
      ),
    );
  }
}

class _LocalMovementsList extends ConsumerWidget {
  const _LocalMovementsList({required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final repo = ref.watch(repositoryProvider);

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          return FutureBuilder<Project?>(
            future: repo.primaryActiveProject(clientId),
            builder: (context, projectSnap) {
              if (projectSnap.connectionState != ConnectionState.done) {
                return _MovementsShell(
                  title: l10n.movements,
                  body: const Center(child: CircularProgressIndicator()),
                );
              }
              final project = projectSnap.data;
              if (project == null) {
                return _MovementsShell(
                  title: l10n.movements,
                  body: ListView(
                    padding: const EdgeInsets.all(AppSize.screenPadding),
                    children: [
                      AppCard(
                        child: AppFallback.section(
                          icon: Icons.receipt_long_outlined,
                          title: l10n.clientDetailNoMovements,
                        ),
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
                      body: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (mapsSnap.hasError) {
                    return _MovementsShell(
                      title: l10n.movements,
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
                      body: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  return _MovementsShell(
                    title: l10n.movements,
                    body: StreamBuilder<List<Transaction>>(
                      stream: repo.watchProjectTransactions(project.id),
                      builder: (context, snap) {
                        final tx = snap.data ?? [];
                        final sorted = [...tx]..sort((a, b) => b.date.compareTo(a.date));
                        final lines = movementLinesFromTransactions(
                          sorted,
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
                          itemBuilder: (context, index) {
                            final line = lines[index];
                            return InteractiveMovementCard(
                              line: line,
                              localeCode: localeCode,
                              mutationsEnabled: true,
                            );
                          },
                        );
                      },
                    ),
                  );
                },
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
  const _MovementsShell({required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: CustomAppBar(title: title),
      body: body,
    );
  }
}
