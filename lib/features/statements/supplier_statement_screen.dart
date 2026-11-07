import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/database/database.dart';
import '../../core/money/money_format.dart';
import '../../core/providers/app_providers.dart';
import 'pdf_statement_service.dart';

class SupplierStatementScreen extends ConsumerStatefulWidget {
  const SupplierStatementScreen({super.key, required this.supplierId});

  final String supplierId;

  @override
  ConsumerState<SupplierStatementScreen> createState() =>
      _SupplierStatementScreenState();
}

class _SupplierStatementScreenState
    extends ConsumerState<SupplierStatementScreen> {
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
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(data.supplier.name,
                  style: Theme.of(context).textTheme.titleLarge),
              ListTile(
                title: Text(l10n.period),
                subtitle: Text(
                    '${_start.day}/${_start.month} — ${_end.day}/${_end.month}'),
              ),
              ListTile(
                title: Text(l10n.openingBalance),
                trailing:
                    Text(MoneyFormat.formatPiastres(data.openingPiastres)),
              ),
              ListTile(
                title: Text(l10n.spent),
                trailing: Text(MoneyFormat.formatPiastres(data.periodPiastres)),
              ),
              ListTile(
                title: Text(l10n.closingBalance),
                trailing:
                    Text(MoneyFormat.formatPiastres(data.closingPiastres)),
              ),
              FilledButton.icon(
                onPressed: () => _share(data),
                icon: const Icon(Icons.share),
                label: Text(l10n.sharePdf),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<_Data> _load(repo) async {
    final supplier = await repo.getSupplier(widget.supplierId);
    if (supplier == null) throw StateError('supplier');
    final rows = await repo.supplierTransactions(widget.supplierId);
    var before = 0;
    var period = 0;
    final start = DateTime(_start.year, _start.month, _start.day);
    final end = DateTime(_end.year, _end.month, _end.day, 23, 59, 59);
    for (final t in rows) {
      if (t.date.isBefore(start)) {
        before += t.amountPiastres as int;
      } else if (!t.date.isAfter(end)) {
        period += t.amountPiastres as int;
      }
    }
    return _Data(
      supplier: supplier,
      openingPiastres: before,
      periodPiastres: period,
      closingPiastres: before + period,
      rows: rows,
    );
  }

  Future<void> _share(_Data data) async {
    final bytes = await PdfStatementService().buildSupplierStatement(
      supplier: data.supplier,
      openingPiastres: data.openingPiastres,
      periodPiastres: data.periodPiastres,
      closingPiastres: data.closingPiastres,
      rows: data.rows,
      periodStart: _start,
      periodEnd: _end,
    );
    await Share.shareXFiles([
      XFile.fromData(bytes,
          mimeType: 'application/pdf', name: 'bnood-supplier.pdf'),
    ]);
  }
}

class _Data {
  _Data({
    required this.supplier,
    required this.openingPiastres,
    required this.periodPiastres,
    required this.closingPiastres,
    required this.rows,
  });
  final Supplier supplier;
  final int openingPiastres;
  final int periodPiastres;
  final int closingPiastres;
  final List<Transaction> rows;
}
