import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';

class ItemsScreen extends ConsumerWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navItems)),
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
              );
            },
          );
        },
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
