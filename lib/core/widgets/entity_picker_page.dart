import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';

/// In-sheet entity list; pops with selected id string.
class EntityPickerPage extends StatelessWidget {
  const EntityPickerPage({
    super.key,
    required this.title,
    required this.entries,
    required this.onCreateRoute,
  });

  final String title;
  final List<(String id, String label)> entries;
  final Widget Function() onCreateRoute;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: BackButton(onPressed: () => Navigator.maybePop(context)),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.createNew),
            onTap: () async {
              final created = await Navigator.of(context).push<String>(
                MaterialPageRoute(builder: (_) => onCreateRoute()),
              );
              if (created != null && context.mounted) {
                Navigator.pop(context, created);
              }
            },
          ),
          for (final e in entries)
            ListTile(
              title: Text(e.$2),
              onTap: () => Navigator.pop(context, e.$1),
            ),
        ],
      ),
    );
  }
}
