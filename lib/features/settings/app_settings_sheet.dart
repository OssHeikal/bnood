import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/settings_provider.dart';
import '../../core/widgets/bnood_modal_sheet.dart';

Future<void> showAppSettingsSheet(BuildContext context) {
  return BnoodModalSheet.show<void>(
    context: context,
    builder: (_) => const AppSettingsSheet(),
  );
}

class AppSettingsSheet extends ConsumerWidget {
  const AppSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.titleLarge),
            ListTile(
              title: const Text('Theme'),
              subtitle: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('System')),
                  ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                ],
                selected: {themeMode},
                onSelectionChanged: (s) =>
                    ref.read(themeModeProvider.notifier).state = s.first,
              ),
            ),
            ListTile(
              title: const Text('Language'),
              subtitle: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'ar', label: Text(l10n.appTitle)),
                  const ButtonSegment(value: 'en', label: Text('English')),
                ],
                selected: {locale.languageCode},
                onSelectionChanged: (s) {
                  ref.read(localeProvider.notifier).state = Locale(s.first);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
