import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/custom_bottom_sheet.dart';
import '../vouchers/inline_create_routes.dart';

class ItemsScreen extends ConsumerWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navItems)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CustomBottomSheet.show(
          context: context,
          builder: (_) => const InlineCreateItemPage(),
          title: l10n.item,
        ),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: ref.watch(repositoryProvider).watchActiveItems(),
        builder: (context, snap) {
          final items = snap.data ?? [];
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      AppColors.accent(item.colorKey).withOpacity(0.15),
                  child: Icon(_iconData(item.iconName),
                      color: AppColors.accent(item.colorKey)),
                ),
                title: Text(item.name),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'archive') {
                      await ref.read(repositoryProvider).archiveItem(item.id);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'archive', child: Text(l10n.archive))
                  ],
                ),
                onTap: () => _editItem(context, ref, item.id, item.name),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _editItem(
      BuildContext context, WidgetRef ref, String id, String name) async {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: name);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: ctrl,
                decoration: InputDecoration(labelText: l10n.item)),
            AppButton(
              label: l10n.save,
              onPressed: () async {
                await ref
                    .read(repositoryProvider)
                    .updateItem(id: id, name: ctrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconData(String name) {
    return switch (name) {
      'construction' => Icons.construction,
      'plumbing' => Icons.plumbing,
      'electrical_services' => Icons.electrical_services,
      'kitchen' => Icons.kitchen,
      'local_shipping' => Icons.local_shipping,
      _ => Icons.category,
    };
  }
}
