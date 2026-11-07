import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/widgets/app_button.dart';

class InlineCreateClientPage extends ConsumerStatefulWidget {
  const InlineCreateClientPage({super.key});

  @override
  ConsumerState<InlineCreateClientPage> createState() =>
      _InlineCreateClientPageState();
}

class _InlineCreateClientPageState
    extends ConsumerState<InlineCreateClientPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addClient)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.clientName)),
            TextField(
                controller: _phone,
                decoration: InputDecoration(labelText: l10n.phoneOptional)),
            const Spacer(),
            AppButton(
              label: l10n.save,
              onPressed: () async {
                if (_name.text.trim().isEmpty) return;
                final client = await ref.read(repositoryProvider).createClient(
                      name: _name.text.trim(),
                      phone: _phone.text.trim().isEmpty
                          ? null
                          : _phone.text.trim(),
                    );
                if (context.mounted) Navigator.pop(context, client.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class InlineCreateItemPage extends ConsumerStatefulWidget {
  const InlineCreateItemPage({super.key});

  @override
  ConsumerState<InlineCreateItemPage> createState() =>
      _InlineCreateItemPageState();
}

class _InlineCreateItemPageState extends ConsumerState<InlineCreateItemPage> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.item)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.item)),
            const Spacer(),
            AppButton(
              label: l10n.save,
              onPressed: () async {
                if (_name.text.trim().isEmpty) return;
                final item = await ref.read(repositoryProvider).createItem(
                      name: _name.text.trim(),
                      colorKey: 'teal',
                      iconName: 'category',
                    );
                if (context.mounted) Navigator.pop(context, item.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
