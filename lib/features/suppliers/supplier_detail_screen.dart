import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
          appBar: AppBar(
            title: Text(l10n.suppliers),
            actions: [
              IconButton(
                icon: const Icon(Icons.description_outlined),
                onPressed: () =>
                    context.push('/suppliers/$supplierId/statement'),
              ),
            ],
          ),
          body: ListView(
            children: [
              ListTile(
                  title: Text(l10n.spent),
                  trailing: Text(MoneyFormat.formatPiastres(total))),
              for (final t in tx)
                ListTile(
                  leading: const Icon(Icons.north_east, color: Colors.red),
                  title: Text(MoneyFormat.formatPiastres(t.amountPiastres)),
                  subtitle: Text(t.description ?? ''),
                  trailing: Text('${t.date.day}/${t.date.month}'),
                ),
            ],
          ),
        );
      },
    );
  }
}
