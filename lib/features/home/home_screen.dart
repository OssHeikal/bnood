import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money/money_format.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/dashboard_providers.dart';
import '../settings/app_settings_sheet.dart';
import '../vouchers/voucher_launcher.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final totals = ref.watch(homeTotalsProvider);
    final clients = ref.watch(activeClientsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => showAppSettingsSheet(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          totals.when(
            data: (t) => Row(
              children: [
                Expanded(
                    child: _StatCard(
                        title: l10n.received,
                        amount: t.receivedPiastres,
                        color: Colors.green)),
                const SizedBox(width: 8),
                Expanded(
                    child: _StatCard(
                        title: l10n.spent,
                        amount: t.spentPiastres,
                        color: Colors.red)),
                const SizedBox(width: 8),
                Expanded(
                    child: _StatCard(
                        title: l10n.remaining,
                        amount: t.remainingPiastres,
                        color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
          ),
          const SizedBox(height: 24),
          Text(l10n.activeClients,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          clients.when(
            data: (list) => Column(
              children: [
                for (final c in list)
                  FutureBuilder(
                    future: _clientBalance(ref, c.id),
                    builder: (context, snap) {
                      final bal = snap.data ?? 0;
                      return ListTile(
                        title: Text(c.name),
                        trailing: Text(MoneyFormat.formatPiastres(bal)),
                        onTap: () => context.push('/clients/${c.id}'),
                      );
                    },
                  ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('$e'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.go('/directory'),
            icon: const Icon(Icons.storefront),
            label: Text(l10n.navDirectory),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => VoucherLauncher.openFresh(context),
            icon: const Icon(Icons.receipt_long),
            label: Text(l10n.navAdd),
          ),
        ],
      ),
    );
  }

  Future<int> _clientBalance(WidgetRef ref, String clientId) async {
    final repo = ref.read(repositoryProvider);
    final project = await repo.primaryActiveProject(clientId);
    if (project == null) return 0;
    final bal = await repo.projectBalance(project.id);
    return bal.balancePiastres;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.title, required this.amount, required this.color});

  final String title;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(MoneyFormat.formatPiastres(amount),
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
