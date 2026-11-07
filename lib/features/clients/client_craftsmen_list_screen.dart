import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/ledger_math.dart';
import '../../core/money/money_format.dart';
import '../../core/providers/app_providers.dart';
import '../../core/repositories/bnood_repository.dart';

class ClientCraftsmenListScreen extends ConsumerWidget {
  const ClientCraftsmenListScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(repositoryProvider);
    return FutureBuilder(
      future: _load(repo),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final rows = snap.data!;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.craftsmen)),
          body: ListView(
            children: [
              for (final r in rows)
                ListTile(
                  title: Text(r.name),
                  subtitle: Text('${l10n.paid}: ${MoneyFormat.formatPiastres(r.paid)}'),
                  trailing: r.remaining != null ? Text(MoneyFormat.formatPiastres(r.remaining!)) : null,
                ),
            ],
          ),
        );
      },
    );
  }

  Future<List<_Row>> _load(BnoodRepository repo) async {
    final project = await repo.primaryActiveProject(clientId);
    if (project == null) return [];
    final agreements = await repo.agreementsForProject(project.id);
    final tx = await repo.transactionsForProject(project.id);
    final craftsmen = await repo.watchActiveCraftsmen().first;
    return [
      for (final a in agreements)
        () {
          final c = craftsmen.where((x) => x.id == a.craftsmanId).firstOrNull;
          if (c == null) return null;
          final paid = LedgerMath.craftsmanPaidPiastres(rows: tx, craftsmanId: a.craftsmanId);
          return _Row(
            name: c.name,
            paid: paid,
            remaining: LedgerMath.craftsmanRemainingPiastres(
              initialAmountPiastres: a.initialAmountPiastres,
              paidPiastres: paid,
            ),
          );
        }(),
    ].whereType<_Row>().toList();
  }
}

class _Row {
  _Row({required this.name, required this.paid, this.remaining});
  final String name;
  final int paid;
  final int? remaining;
}
