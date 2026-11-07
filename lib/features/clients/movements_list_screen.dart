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
import '../../core/widgets/foundation_app_bar_title.dart';
import '../home/home_foundation_scope.dart';
import 'client_movement_lines.dart';
import 'widgets/interactive_movement_card.dart';

class MovementsListScreen extends ConsumerWidget {
  const MovementsListScreen({super.key, required this.clientId});

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
                          icon: Icons.folder_off_outlined,
                          title: l10n.homeLoadErrorTitle,
                          description: l10n.clientDetailNoMovements,
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
                              title: l10n.homeLoadErrorTitle,
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
      appBar: AppBar(
        backgroundColor: colors.canvas,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        title: FoundationAppBarTitle(title: title),
      ),
      body: body,
    );
  }
}
