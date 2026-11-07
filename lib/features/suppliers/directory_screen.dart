import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../core/widgets/custom_bottom_sheet.dart';
import '../vouchers/inline_create_routes.dart';

class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key});

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navDirectory),
          bottom: TabBar(
              tabs: [Tab(text: l10n.suppliers), Tab(text: l10n.craftsmen)]),
        ),
        body: const TabBarView(
          children: [_SupplierTab(), _CraftsmanTab()],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final tab = DefaultTabController.of(context).index;
            if (tab == 0) {
              CustomBottomSheet.show(
                context: context,
                builder: (_) => const InlineCreateSupplierPage(),
                title: l10n.supplier,
              );
            } else {
              CustomBottomSheet.show(
                context: context,
                builder: (_) => const InlineCreateCraftsmanPage(),
                title: l10n.craftsman,
              );
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _SupplierTab extends ConsumerWidget {
  const _SupplierTab();

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
              trailing: IconButton(
                icon: const Icon(Icons.archive_outlined),
                onPressed: () =>
                    ref.read(repositoryProvider).archiveSupplier(s.id),
              ),
              onTap: () => context.push('/suppliers/${s.id}'),
            );
          },
        );
      },
    );
  }
}

class _CraftsmanTab extends ConsumerWidget {
  const _CraftsmanTab();

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
              trailing: IconButton(
                icon: const Icon(Icons.archive_outlined),
                onPressed: () =>
                    ref.read(repositoryProvider).archiveCraftsman(c.id),
              ),
              onTap: () => context.push('/craftsmen/${c.id}'),
            );
          },
        );
      },
    );
  }
}
