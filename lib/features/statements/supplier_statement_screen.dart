import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/database/database.dart';
import '../../core/money/money_format.dart';
import '../../core/money/period_bounds.dart';
import '../../core/money/supplier_period_math.dart';
import '../../core/providers/app_providers.dart';
import '../../core/repositories/bnood_repository.dart';
import 'pdf_statement_service.dart';
import 'statement_period_controls.dart';

class SupplierStatementScreen extends ConsumerStatefulWidget {
  const SupplierStatementScreen({super.key, required this.supplierId});

  final String supplierId;

  @override
  ConsumerState<SupplierStatementScreen> createState() => _SupplierStatementScreenState();
}

class _SupplierStatementScreenState extends ConsumerState<SupplierStatementScreen> {
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
              StatementPeriodControls(bounds: _bounds, onChanged: (b) => setState(() => _bounds = b)),
              Text(data.supplier.name, style: Theme.of(context).textTheme.titleLarge),
              ListTile(
                title: Text(l10n.openingBalance),
                trailing: Text(MoneyFormat.formatPiastres(data.totals.openingPaidPiastres)),
              ),
              ListTile(
                title: Text(l10n.spent),
                trailing: Text(MoneyFormat.formatPiastres(data.totals.periodPaidPiastres)),
              ),
              ListTile(
                title: Text(l10n.closingBalance),
                trailing: Text(MoneyFormat.formatPiastres(data.totals.closingPaidPiastres)),
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

  Future<_Data> _load(BnoodRepository repo) async {
    final supplier = await repo.getSupplier(widget.supplierId);
    if (supplier == null) throw StateError('supplier');
    final rows = await repo.supplierTransactions(widget.supplierId);
    final totals = SupplierPeriodMath.totals(supplierSpends: rows, bounds: _bounds);
    final periodRows = rows.where((t) => _bounds.containsLocalDate(t.date)).toList();
    return _Data(supplier: supplier, totals: totals, periodRows: periodRows);
  }

  Future<void> _share(_Data data) async {
    final bytes = await PdfStatementService().buildSupplierStatement(
      supplier: data.supplier,
      totals: data.totals,
      periodRows: data.periodRows,
      bounds: _bounds,
    );
    await Share.shareXFiles([XFile.fromData(bytes, mimeType: 'application/pdf', name: 'bnood-supplier.pdf')]);
  }
}

class _Data {
  _Data({required this.supplier, required this.totals, required this.periodRows});
  final Supplier supplier;
  final SupplierPeriodTotals totals;
  final List<Transaction> periodRows;
}
