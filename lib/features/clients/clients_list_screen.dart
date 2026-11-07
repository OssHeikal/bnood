import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../core/widgets/custom_bottom_sheet.dart';
import '../vouchers/inline_create_routes.dart';

class ClientsListScreen extends ConsumerWidget {
  const ClientsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navClients)),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await CustomBottomSheet.show(
            context: context,
            builder: (_) => const InlineCreateClientPage(),
            title: l10n.addClient,
          );
          ref.invalidate(repositoryProvider);
        },
        child: const Icon(Icons.person_add),
      ),
      body: FutureBuilder(
        future: ref.read(repositoryProvider).watchActiveClients(),
        builder: (context, snap) {
          final list = snap.data ?? [];
          if (list.isEmpty) return Center(child: Text(l10n.addClient));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final c = list[i];
              return ListTile(
                title: Text(c.name),
                subtitle: c.phone != null ? Text(c.phone!) : null,
                onTap: () => context.push('/clients/${c.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
