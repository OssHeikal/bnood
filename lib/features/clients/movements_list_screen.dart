import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/database/database.dart';
import '../../core/providers/app_providers.dart';
import '../../core/repositories/bnood_repository.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_fallback.dart';
import '../home/home_foundation_scope.dart';
import '../vouchers/voucher_draft.dart';
import '../vouchers/voucher_launcher.dart';
import 'client_movement_lines.dart';
import 'widgets/client_movement_card.dart';

class MovementsListScreen extends ConsumerWidget {
  const MovementsListScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final repo = ref.watch(repositoryProvider);
    return FutureBuilder<Project?>(
      future: repo.primaryActiveProject(clientId),
      builder: (context, projectSnap) {
        final project = projectSnap.data;
        if (project == null) {
          return HomeFoundationScope(
            child: Scaffold(
              backgroundColor: context.colors.canvas,
              appBar: AppBar(
                backgroundColor: context.colors.canvas,
                surfaceTintColor: Colors.transparent,
                scrolledUnderElevation: 0,
                elevation: 0,
                title: Text(l10n.movements, style: context.text.pageTitle),
              ),
              body: const Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return FutureBuilder<MovementEntityMaps>(
          future: _loadEntityMaps(repo),
          builder: (context, mapsSnap) {
            if (!mapsSnap.hasData) {
              return HomeFoundationScope(
                child: Scaffold(
                  backgroundColor: context.colors.canvas,
                  appBar: AppBar(
                    backgroundColor: context.colors.canvas,
                    surfaceTintColor: Colors.transparent,
                    scrolledUnderElevation: 0,
                    elevation: 0,
                    title: Text(l10n.movements, style: context.text.pageTitle),
                  ),
                  body: const Center(child: CircularProgressIndicator()),
                ),
              );
            }
            final maps = mapsSnap.data!;
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
                      title: Text(l10n.movements, style: text.pageTitle),
                    ),
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
                          separatorBuilder: (_, __) => AppSize.spaceMD.gap,
                          itemBuilder: (context, index) {
                            final line = lines[index];
                            final t = line.transaction;
                            return Dismissible(
                              key: ValueKey(t.id),
                              direction: DismissDirection.endToStart,
                              background: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: colors.spend,
                                  borderRadius: BorderRadius.circular(AppSize.radiusLG),
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.only(end: AppSize.spaceLG),
                                    child: Text(
                                      l10n.delete,
                                      style: text.body.copyWith(color: colors.onError),
                                    ),
                                  ),
                                ),
                              ),
                              confirmDismiss: (_) async {
                                await repo.deleteTransaction(t.id);
                                return true;
                              },
                              child: AppCard(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSize.spaceLG,
                                  vertical: AppSize.spaceXS,
                                ),
                                onTap: () => VoucherLauncher.openEdit(
                                  context,
                                  VoucherDraft(
                                    clientId: clientId,
                                    projectId: project.id,
                                    kind: t.kind,
                                    expenseType: t.expenseType ?? 'materials',
                                    method: t.method,
                                    amountPiastres: t.amountPiastres,
                                    itemId: t.itemId,
                                    supplierId: t.supplierId,
                                    craftsmanId: t.craftsmanId,
                                    description: t.description,
                                    date: t.date,
                                    editingTransactionId: t.id,
                                  ),
                                ),
                                child: ClientMovementCard(
                                  line: line,
                                  localeCode: localeCode,
                                  padding: const EdgeInsets.symmetric(vertical: AppSize.spaceSM),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        );
      },
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
