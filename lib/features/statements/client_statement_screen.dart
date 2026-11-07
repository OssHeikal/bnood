import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/database/database.dart';
import '../../core/money/ledger_math.dart';
import '../../core/money/money_format.dart';
import '../../core/money/period_bounds.dart';
import '../../core/providers/app_providers.dart';
import '../../core/repositories/bnood_repository.dart';
import 'pdf_statement_service.dart';
import 'statement_period_controls.dart';

class ClientStatementScreen extends ConsumerStatefulWidget {
  const ClientStatementScreen({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<ClientStatementScreen> createState() =>
      _ClientStatementScreenState();
}

class _ClientStatementScreenState extends ConsumerState<ClientStatementScreen> {
  late PeriodBounds _bounds = PeriodBounds.normalize(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(repositoryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.statement)),
      body: FutureBuilder(
        key: ValueKey('${_bounds.start}-${_bounds.end}'),
        future: _load(repo),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              StatementPeriodControls(
                bounds: _bounds,
                onChanged: (b) => setState(() => _bounds = b),
              ),
              const SizedBox(height: 12),
              Text(data.client.name,
                  style: Theme.of(context).textTheme.titleLarge),
              _row(l10n.openingBalance, data.totals.openingBalancePiastres),
              _row(l10n.received, data.totals.periodReceivedPiastres),
              _row(l10n.spent, data.totals.periodSpentPiastres),
              _row(l10n.closingBalance, data.totals.closingBalancePiastres),
              const Divider(),
              _row(l10n.materials, data.totals.materialsPiastres),
              _row(l10n.labor, data.totals.laborPiastres),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _sharePdf(data),
                icon: const Icon(Icons.share),
                label: Text(l10n.sharePdf),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, int piastres) {
    return ListTile(
        title: Text(label),
        trailing: Text(MoneyFormat.formatPiastres(piastres)));
  }

  Future<_StatementData> _load(BnoodRepository repo) async {
    final client = await repo.getClient(widget.clientId);
    final project = await repo.primaryActiveProject(widget.clientId);
    if (client == null || project == null) {
      throw StateError('missing');
    }
    final rows = await repo.transactionsForProject(project.id);
    final totals = LedgerMath.periodTotals(
      projectRows: rows,
      periodStart: _bounds.start,
      periodEnd: _bounds.end,
    );
    final periodSpend = rows
        .where((t) => t.kind == 'spend' && _bounds.containsLocalDate(t.date))
        .toList();
    final periodReceive = rows
        .where((t) => t.kind == 'receive' && _bounds.containsLocalDate(t.date))
        .toList();
    final items = await repo.watchActiveItems().first;
    final itemNames = {for (final i in items) i.id: i.name};
    return _StatementData(
      client: client,
      totals: totals,
      periodSpend: periodSpend,
      periodReceive: periodReceive,
      itemNames: itemNames,
    );
  }

  Future<void> _sharePdf(_StatementData data) async {
    final bytes = await PdfStatementService().buildClientStatement(
      client: data.client,
      totals: data.totals,
      periodSpend: data.periodSpend,
      periodReceive: data.periodReceive,
      itemNames: data.itemNames,
      bounds: _bounds,
    );
    await Share.shareXFiles([
      XFile.fromData(bytes,
          mimeType: 'application/pdf', name: 'bnood-statement.pdf'),
    ]);
  }
}

class _StatementData {
  _StatementData({
    required this.client,
    required this.totals,
    required this.periodSpend,
    required this.periodReceive,
    required this.itemNames,
  });
  final Client client;
  final StatementPeriodTotals totals;
  final List<Transaction> periodSpend;
  final List<Transaction> periodReceive;
  final Map<String, String> itemNames;
}
