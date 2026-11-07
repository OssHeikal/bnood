import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/ledger_math.dart';
import '../../core/money/money_format.dart';
import '../../core/providers/app_providers.dart';
import '../../core/repositories/bnood_repository.dart';

class CraftsmanDetailScreen extends ConsumerWidget {
  const CraftsmanDetailScreen({super.key, required this.craftsmanId});

  final String craftsmanId;

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
          appBar: AppBar(title: Text(l10n.craftsman)),
          body: ListView(
            children: [
              for (final r in rows)
                ListTile(
                  title: Text(r.projectName),
                  subtitle: Text(
                      '${l10n.paid}: ${MoneyFormat.formatPiastres(r.paid)}'),
                  trailing: r.remaining != null
                      ? Text(MoneyFormat.formatPiastres(r.remaining!))
                      : null,
                ),
            ],
          ),
        );
      },
    );
  }

  Future<List<_Row>> _load(BnoodRepository repo) async {
    final projects = await repo.allProjects();
    final result = <_Row>[];
    for (final p in projects) {
      final tx = await repo.transactionsForProject(p.id);
      final paid =
          LedgerMath.craftsmanPaidPiastres(rows: tx, craftsmanId: craftsmanId);
      if (paid == 0) continue;
      final agreements = await repo.agreementsForProject(p.id);
      final ag =
          agreements.where((a) => a.craftsmanId == craftsmanId).firstOrNull;
      result.add(_Row(
        projectName: p.name,
        paid: paid,
        remaining: LedgerMath.craftsmanRemainingPiastres(
          initialAmountPiastres: ag?.initialAmountPiastres,
          paidPiastres: paid,
        ),
      ));
    }
    return result;
  }
}

class _Row {
  _Row({required this.projectName, required this.paid, this.remaining});
  final String projectName;
  final int paid;
  final int? remaining;
}
