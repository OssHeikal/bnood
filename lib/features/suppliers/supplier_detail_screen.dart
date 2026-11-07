import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/money_format.dart';
import '../../core/providers/app_providers.dart';

class SupplierDetailScreen extends ConsumerWidget {
  const SupplierDetailScreen({super.key, required this.supplierId});

  final String supplierId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(repositoryProvider);
    return FutureBuilder(
      future: repo.supplierTransactions(supplierId),
      builder: (context, snap) {
        final tx = snap.data ?? [];
        final total = tx.fold<int>(0, (s, t) => s + t.amountPiastres);
        return Scaffold(
          appBar: AppBar(title: Text(l10n.suppliers)),
          body: ListView(
            children: [
              ListTile(
                  title: Text(l10n.spent),
                  trailing: Text(MoneyFormat.formatPiastres(total))),
              for (final t in tx)
                ListTile(
                  title: Text(MoneyFormat.formatPiastres(t.amountPiastres)),
                  subtitle: Text(t.description ?? ''),
                ),
            ],
          ),
        );
      },
    );
  }
}
