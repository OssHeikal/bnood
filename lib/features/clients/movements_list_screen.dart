import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/money_format.dart';
import '../../core/providers/app_providers.dart';
import '../vouchers/voucher_draft.dart';
import '../vouchers/voucher_launcher.dart';

class MovementsListScreen extends ConsumerWidget {
  const MovementsListScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(repositoryProvider);
    return FutureBuilder(
      future: repo.primaryActiveProject(clientId),
      builder: (context, projectSnap) {
        final project = projectSnap.data;
        if (project == null) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return Scaffold(
          appBar: AppBar(title: Text(l10n.movements)),
          body: StreamBuilder(
            stream: repo.watchProjectTransactions(project.id),
            builder: (context, snap) {
              final list = snap.data ?? [];
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final t = list[i];
                  return Dismissible(
                    key: ValueKey(t.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(l10n.delete,
                            style: const TextStyle(color: Colors.white))),
                    confirmDismiss: (_) async {
                      await repo.deleteTransaction(t.id);
                      return true;
                    },
                    child: ListTile(
                      leading: Icon(
                          t.kind == 'receive'
                              ? Icons.south_west
                              : Icons.north_east,
                          color:
                              t.kind == 'receive' ? Colors.green : Colors.red),
                      title: Text(MoneyFormat.formatPiastres(t.amountPiastres)),
                      subtitle: Text(t.description ?? ''),
                      onTap: () => VoucherLauncher.openEdit(
                        context,
                        VoucherDraft(
                          clientId: clientId,
                          projectId: project.id,
                          kind: t.kind,
                          expenseType: t.expenseType ?? 'materials',
                          method: t.method,
                          amountPiastres: t.amountPiastres,
                          itemId: t.itemId,
                          supplierId: t.supplierId,
                          craftsmanId: t.craftsmanId,
                          description: t.description,
                          date: t.date,
                          editingTransactionId: t.id,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
