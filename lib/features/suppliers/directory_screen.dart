import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';

class DirectoryScreen extends ConsumerWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navDirectory),
          bottom: TabBar(
              tabs: [Tab(text: l10n.suppliers), Tab(text: l10n.craftsmen)]),
        ),
        body: TabBarView(
          children: [
            _SupplierTab(),
            _CraftsmanTab(),
          ],
        ),
      ),
    );
  }
}

class _SupplierTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
      stream: ref.watch(repositoryProvider).watchActiveSuppliers(),
      builder: (context, snap) {
        final list = snap.data ?? [];
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final s = list[i];
            return ListTile(
                title: Text(s.name),
                onTap: () => context.push('/suppliers/${s.id}'));
          },
        );
      },
    );
  }
}

class _CraftsmanTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
      stream: ref.watch(repositoryProvider).watchActiveCraftsmen(),
      builder: (context, snap) {
        final list = snap.data ?? [];
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final c = list[i];
            return ListTile(
                title: Text(c.name),
                subtitle: Text(c.trade ?? ''),
                onTap: () => context.push('/craftsmen/${c.id}'));
          },
        );
      },
    );
  }
}
