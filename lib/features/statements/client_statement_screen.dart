import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/database/database.dart';
import '../../core/money/ledger_math.dart';
import '../../core/repositories/bnood_repository.dart';
import '../../core/money/money_format.dart';
import '../../core/providers/app_providers.dart';
import 'pdf_statement_service.dart';

class ClientStatementScreen extends ConsumerStatefulWidget {
  const ClientStatementScreen({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<ClientStatementScreen> createState() =>
      _ClientStatementScreenState();
}

class _ClientStatementScreenState extends ConsumerState<ClientStatementScreen> {
  DateTime _start = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _end = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(repositoryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.statement)),
      body: FutureBuilder(
        future: _load(repo),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final data = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(data.clientName,
                  style: Theme.of(context).textTheme.titleLarge),
              Text(
                  '${l10n.period}: ${_start.day}/${_start.month} - ${_end.day}/${_end.month}'),
              const SizedBox(height: 12),
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
    if (client == null || project == null) throw StateError('missing');
    final rows = await repo.transactionsForProject(project.id);
    final totals = LedgerMath.periodTotals(
        projectRows: rows, periodStart: _start, periodEnd: _end);
    final periodSpend = rows.where((t) {
      return t.kind == 'spend' &&
          !t.date.isBefore(_start) &&
          !t.date.isAfter(_end);
    }).toList();
    final periodReceive = rows.where((t) {
      return t.kind == 'receive' &&
          !t.date.isBefore(_start) &&
          !t.date.isAfter(_end);
    }).toList();
    final items = await ref.read(repositoryProvider).watchActiveItems().first;
    final itemNames = {for (final i in items) i.id: i.name};
    return _StatementData(
      clientName: client.name,
      client: client,
      projectId: project.id,
      totals: totals,
      periodSpend: periodSpend,
      periodReceive: periodReceive,
      itemNames: itemNames,
      allRows: rows,
    );
  }

  Future<void> _sharePdf(_StatementData data) async {
    final bytes = await PdfStatementService().buildClientStatement(
      client: data.client,
      totals: data.totals,
      periodSpend: data.periodSpend,
      periodReceive: data.periodReceive,
      itemNames: data.itemNames,
      periodStart: _start,
      periodEnd: _end,
    );
    await Share.shareXFiles([
      XFile.fromData(bytes,
          mimeType: 'application/pdf', name: 'bnood-statement.pdf')
    ]);
  }
}

class _StatementData {
  _StatementData({
    required this.clientName,
    required this.client,
    required this.projectId,
    required this.totals,
    required this.periodSpend,
    required this.periodReceive,
    required this.itemNames,
    required this.allRows,
  });

  final String clientName;
  final Client client;
  final String projectId;
  final StatementPeriodTotals totals;
  final List<Transaction> periodSpend;
  final List<Transaction> periodReceive;
  final Map<String, String> itemNames;
  final List allRows;
}
