import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/repositories/bnood_repository.dart';

import '../../core/database/database.dart';
import '../../core/money/ledger_math.dart';
import '../../core/money/money_format.dart';
import '../../core/providers/app_providers.dart';
import '../vouchers/voucher_launcher.dart';
import 'craftsman_assignments_sheet.dart';
import 'engineer_edit_sheet.dart';

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(repositoryProvider);
    return FutureBuilder(
      future: _load(repo),
      builder: (context, snap) {
        if (!snap.hasData)
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        final data = snap.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text(data.client.name),
            actions: [
              if (data.client.phone != null)
                IconButton(
                  icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                  onPressed: () => _openWhatsApp(data.client.phone!),
                ),
              IconButton(
                icon: const Icon(Icons.description_outlined),
                onPressed: () => context.push('/clients/$clientId/statement'),
              ),
              IconButton(
                icon: const Icon(Icons.archive_outlined),
                onPressed: () async {
                  await ref.read(repositoryProvider).archiveClient(clientId);
                  if (context.mounted) context.pop();
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _BalanceHeader(balance: data.balance),
              const SizedBox(height: 12),
              _EngineerCard(
                project: data.project,
                profit: data.estimatedProfit,
                client: data.client,
                onEdit: () => showEngineerEditSheet(
                  context: context,
                  clientId: clientId,
                  projectId: data.project.id,
                  clientName: data.client.name,
                  phone: data.client.phone,
                  unitAddress: data.project.unitAddress,
                  engineerBasisPoints: data.project.engineerBasisPoints,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.craftsmen,
                      style: Theme.of(context).textTheme.titleMedium),
                  TextButton(
                    onPressed: () =>
                        context.push('/clients/$clientId/craftsmen'),
                    child: Text(l10n.seeAll),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => showCraftsmanAssignmentsSheet(
                  context: context,
                  projectId: data.project.id,
                ),
                icon: const Icon(Icons.handyman),
                label: Text(l10n.createNew),
              ),
              ...data.craftsmanPreviews.map((p) => ListTile(
                    title: Text(p.name),
                    subtitle: Text(
                        '${l10n.paid}: ${MoneyFormat.formatPiastres(p.paid)}'
                        '${p.remaining != null ? ' • ${l10n.remaining}: ${MoneyFormat.formatPiastres(p.remaining!)}' : ''}'),
                  )),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.navItems,
                      style: Theme.of(context).textTheme.titleMedium),
                  TextButton(
                    onPressed: () => context.push('/clients/$clientId/items'),
                    child: Text(l10n.seeAll),
                  ),
                ],
              ),
              ...data.topItems.map((e) {
                final total = e.value.totalPiastres;
                return ListTile(
                  title: Text(e.key),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.materials}: ${MoneyFormat.formatPiastres(e.value.materialsPiastres)} • '
                        '${l10n.labor}: ${MoneyFormat.formatPiastres(e.value.laborPiastres)}',
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: total == 0
                              ? 0
                              : e.value.materialsPiastres / total,
                          minHeight: 8,
                          backgroundColor: Colors.red.withOpacity(0.15),
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(MoneyFormat.formatPiastres(total)),
                );
              }),
              const SizedBox(height: 8),
              Text(l10n.movements,
                  style: Theme.of(context).textTheme.titleMedium),
              ...data.latestMovements.map((t) => _MovementTile(t: t)),
              TextButton(
                  onPressed: () => context.push('/clients/$clientId/movements'),
                  child: Text(l10n.seeAll)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => VoucherLauncher.openForClient(
                        context,
                        clientId: clientId,
                        projectId: data.project.id,
                        clientLabel: data.client.name,
                        kind: 'receive',
                      ),
                      child: Text(l10n.receive),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      style:
                          FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => VoucherLauncher.openForClient(
                        context,
                        clientId: clientId,
                        projectId: data.project.id,
                        clientLabel: data.client.name,
                        kind: 'spend',
                      ),
                      child: Text(l10n.spend),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openWhatsApp(String phone) async {
    final normalized = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/$normalized');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<_DetailData> _load(BnoodRepository repo) async {
    final clients = await repo.watchActiveClients();
    final client = clients.firstWhere((c) => c.id == clientId);
    final project = await repo.primaryActiveProject(clientId);
    if (project == null) throw StateError('Project missing');
    final tx = await repo.transactionsForProject(project.id);
    final balance = LedgerMath.projectBalance(tx).balancePiastres;
    final profit = project.engineerBasisPoints == null
        ? null
        : MoneyFormat.estimatedProfitPiastres(
            totalSpendPiastres: LedgerMath.projectBalance(tx).spentPiastres,
            engineerBasisPoints: project.engineerBasisPoints!,
          );
    final agreements = await repo.agreementsForProject(project.id);
    final craftsmen = await repo.watchActiveCraftsmen().first;
    final previews = <_CraftsmanPreview>[];
    for (final a in agreements.take(3)) {
      final c = craftsmen.where((x) => x.id == a.craftsmanId).firstOrNull;
      if (c == null) continue;
      final paid = LedgerMath.craftsmanPaidPiastres(
          rows: tx, craftsmanId: a.craftsmanId);
      previews.add(_CraftsmanPreview(
        name: c.name,
        paid: paid,
        remaining: LedgerMath.craftsmanRemainingPiastres(
            initialAmountPiastres: a.initialAmountPiastres, paidPiastres: paid),
      ));
    }
    final spend = tx.where((t) => t.kind == 'spend').toList();
    final breakdown = LedgerMath.itemBreakdown(spend);
    final items = await repo.watchActiveItems().first;
    final itemNames = {for (final i in items) i.id: i.name};
    final topItems = breakdown.entries.toList()
      ..sort((a, b) => b.value.totalPiastres.compareTo(a.value.totalPiastres));
    final topItemsNamed = topItems
        .take(3)
        .map((e) => MapEntry(itemNames[e.key] ?? e.key, e.value))
        .toList();
    final latest = [...tx]..sort((a, b) => b.date.compareTo(a.date));
    return _DetailData(
      client: client,
      project: project,
      balance: balance,
      estimatedProfit: profit,
      craftsmanPreviews: previews,
      topItems: topItemsNamed,
      latestMovements: latest.take(5).toList(),
    );
  }
}

class _DetailData {
  _DetailData({
    required this.client,
    required this.project,
    required this.balance,
    required this.estimatedProfit,
    required this.craftsmanPreviews,
    required this.topItems,
    required this.latestMovements,
  });

  final Client client;
  final Project project;
  final int balance;
  final int? estimatedProfit;
  final List<_CraftsmanPreview> craftsmanPreviews;
  final List<MapEntry<String, ItemExpenseBreakdown>> topItems;
  final List<Transaction> latestMovements;
}

class _CraftsmanPreview {
  _CraftsmanPreview({required this.name, required this.paid, this.remaining});
  final String name;
  final int paid;
  final int? remaining;
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.balance});
  final int balance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.remaining, style: Theme.of(context).textTheme.labelLarge),
            Text(MoneyFormat.formatPiastres(balance),
                style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _EngineerCard extends StatelessWidget {
  const _EngineerCard({
    required this.project,
    required this.profit,
    required this.client,
    required this.onEdit,
  });
  final Project project;
  final int? profit;
  final Client client;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        onTap: onEdit,
        title: Text(client.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (client.phone != null) Text(client.phone!),
            if (project.unitAddress != null && project.unitAddress!.isNotEmpty)
              Text(project.unitAddress!),
            if (project.engineerBasisPoints != null)
              Text(
                '${l10n.engineerFee}: ${profit == null ? '—' : MoneyFormat.formatPiastres(profit!)}',
              ),
          ],
        ),
        trailing: const Icon(Icons.edit),
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({required this.t});
  final Transaction t;

  @override
  Widget build(BuildContext context) {
    final isReceive = t.kind == 'receive';
    return ListTile(
      leading: Icon(isReceive ? Icons.south_west : Icons.north_east,
          color: isReceive ? Colors.green : Colors.red),
      title: Text(MoneyFormat.formatPiastres(t.amountPiastres)),
      subtitle: Text(t.description ?? ''),
      trailing: Text('${t.date.day}/${t.date.month}'),
    );
  }
}
