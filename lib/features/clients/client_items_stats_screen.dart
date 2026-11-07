import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/ledger_math.dart';
import '../../core/money/money_format.dart';
import '../../core/providers/app_providers.dart';

class ClientItemsStatsScreen extends ConsumerWidget {
  const ClientItemsStatsScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(repositoryProvider);
    return FutureBuilder(
      future: _load(repo),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final rows = snap.data!;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.navItems)),
          body: ListView(
            children: [
              for (final r in rows)
                ListTile(
                  title: Text(r.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${l10n.materials}: ${MoneyFormat.formatPiastres(r.materials)}'),
                      Text(
                          '${l10n.labor}: ${MoneyFormat.formatPiastres(r.labor)}'),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: r.total == 0 ? 0 : r.materials / r.total,
                          minHeight: 8,
                          backgroundColor: Colors.red.withOpacity(0.2),
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(MoneyFormat.formatPiastres(r.total)),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<List<_ItemRow>> _load(repo) async {
    final project = await repo.primaryActiveProject(clientId);
    if (project == null) return [];
    final tx = await repo.transactionsForProject(project.id);
    final spend = tx.where((t) => t.kind == 'spend').toList();
    final breakdown = LedgerMath.itemBreakdown(spend);
    final items = await repo.watchActiveItems().first;
    final names = {for (final i in items) i.id: i.name};
    return breakdown.entries
        .map((e) => _ItemRow(
              name: names[e.key] ?? e.key,
              materials: e.value.materialsPiastres,
              labor: e.value.laborPiastres,
              total: e.value.totalPiastres,
            ))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
  }
}

class _ItemRow {
  _ItemRow({
    required this.name,
    required this.materials,
    required this.labor,
    required this.total,
  });
  final String name;
  final int materials;
  final int labor;
  final int total;
}
