import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/widgets/app_pressable.dart';
import '../../core/widgets/bnood_modal_sheet.dart';
import '../../core/widgets/bounded_sheet_navigator.dart';
import '../../core/widgets/grouped_list_divider.dart';
import '../../core/widgets/sheet_drag_handle.dart';
import '../../app/widgets/shell_nav_icon.dart';

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
    final persistenceOk = ref.watch(settingsPersistenceAvailableProvider);
    final brightness = Theme.of(context).brightness;
    final colors = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
    final text = AppText.fromColors(colors);
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final maxHeight = SheetContentBounds.viewportCap(MediaQuery.of(context));

    return Theme(
      data: Theme.of(context).copyWith(extensions: [colors, text]),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSize.spaceMD.gap,
                  const SheetDragHandle(),
                  AppSize.spaceLG.gap,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
                    child: Text(
                      l10n.settingsTitle,
                      style: context.text.pageTitle,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  if (!persistenceOk) ...[
                    AppSize.spaceSM.gap,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
                      child: Text(
                        l10n.settingsPersistenceUnavailable,
                        style: context.text.caption.copyWith(color: context.colors.onSurfaceMuted),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                  AppSize.spaceXL.gap,
                  _SettingsSection(
                    title: l10n.settingsThemeSection,
                    dividerKind: GroupedListDividerKind.insetStart,
                    children: [
                      _SettingsOptionRow(
                        label: l10n.settingsThemeSystem,
                        selected: themeMode == ThemeMode.system,
                        onTap: () => ref.read(themeModeProvider.notifier).setTheme(ThemeMode.system),
                      ),
                      _SettingsOptionRow(
                        label: l10n.settingsThemeLight,
                        selected: themeMode == ThemeMode.light,
                        onTap: () => ref.read(themeModeProvider.notifier).setTheme(ThemeMode.light),
                      ),
                      _SettingsOptionRow(
                        label: l10n.settingsThemeDark,
                        selected: themeMode == ThemeMode.dark,
                        onTap: () => ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark),
                      ),
                    ],
                  ),
                  AppSize.spaceXL.gap,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
                    child: Divider(height: 1, thickness: AppSize.borderWidthHairline, color: colors.outlineSubtle),
                  ),
                  AppSize.spaceXL.gap,
                  _SettingsSection(
                    title: l10n.settingsLanguageSection,
                    dividerKind: GroupedListDividerKind.insetStart,
                    children: [
                      _SettingsOptionRow(
                        label: l10n.settingsLanguageArabic,
                        selected: locale.languageCode == 'ar',
                        onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('ar')),
                      ),
                      _SettingsOptionRow(
                        label: l10n.settingsLanguageEnglish,
                        selected: locale.languageCode == 'en',
                        onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
                      ),
                    ],
                  ),
                  AppSize.spaceLG.gap,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
    required this.dividerKind,
  });

  final String title;
  final List<_SettingsOptionRow> children;
  final GroupedListDividerKind dividerKind;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(AppSize.spaceLG, 0, AppSize.spaceLG, AppSize.spaceSM),
          child: Text(
            title,
            style: context.text.groupTitle,
            textAlign: TextAlign.start,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceSunken,
              borderRadius: BorderRadius.circular(AppSize.radiusSM),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    GroupedListDivider.build(context, kind: dividerKind, color: colors.outlineSubtle),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsOptionRow extends StatelessWidget {
  const _SettingsOptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _trailingSlot = AppSize.iconCompact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final titleStyle = selected ? text.bodyEmphasis : text.body;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: AppPressable(
        onPressed: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSize.hitMin),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSize.spaceMD,
              AppSize.spaceSM + 2,
              AppSize.spaceMD,
              AppSize.spaceSM + 2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: titleStyle,
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(
                  width: _trailingSlot,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: selected
                        ? ShellNavIcon(
                            asset: Assets.icons.checkOutline,
                            color: colors.primary,
                            size: AppSize.iconCompact,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
