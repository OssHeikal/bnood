import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/widgets/grouped_list_divider.dart';
import 'settings_list_widgets.dart';

/// Theme and language only (menu sub-screen).
class AppPreferencesBody extends ConsumerWidget {
  const AppPreferencesBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final persistenceOk = ref.watch(settingsPersistenceAvailableProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!persistenceOk) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
            child: Text(
              l10n.settingsPersistenceUnavailable,
              style: context.text.caption.copyWith(color: context.colors.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
          ),
          AppSize.spaceMD.gap,
        ],
        SettingsListSection(
          title: l10n.settingsThemeSection,
          dividerKind: GroupedListDividerKind.insetStart,
          children: [
            SettingsOptionRow(
              label: l10n.settingsThemeSystem,
              selected: themeMode == ThemeMode.system,
              onTap: () => ref.read(themeModeProvider.notifier).setTheme(ThemeMode.system),
            ),
            SettingsOptionRow(
              label: l10n.settingsThemeLight,
              selected: themeMode == ThemeMode.light,
              onTap: () => ref.read(themeModeProvider.notifier).setTheme(ThemeMode.light),
            ),
            SettingsOptionRow(
              label: l10n.settingsThemeDark,
              selected: themeMode == ThemeMode.dark,
              onTap: () => ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark),
            ),
          ],
        ),
        AppSize.spaceXL.gap,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
          child: Divider(height: 1, thickness: AppSize.borderWidthHairline, color: context.colors.outlineSubtle),
        ),
        AppSize.spaceXL.gap,
        SettingsListSection(
          title: l10n.settingsLanguageSection,
          dividerKind: GroupedListDividerKind.insetStart,
          children: [
            SettingsOptionRow(
              label: l10n.settingsLanguageArabic,
              selected: locale.languageCode == 'ar',
              onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('ar')),
            ),
            SettingsOptionRow(
              label: l10n.settingsLanguageEnglish,
              selected: locale.languageCode == 'en',
              onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
            ),
          ],
        ),
      ],
    );
  }
}
