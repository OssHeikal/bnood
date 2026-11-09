import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/theme/app_colors.dart';
import '../core/config/theme/app_size.dart';
import '../core/resources/gen/assets.gen.dart';
import '../core/widgets/app_fallback.dart';
import '../core/widgets/app_pressable.dart';
import '../core/widgets/foundation_app_bar.dart';
import '../features/home/home_foundation_scope.dart';
import '../features/settings/app_settings_sheet.dart';
import 'app_shell_online_tabs.dart';
import 'widgets/shell_nav_icon.dart';

/// Renders [child] when the tab is online for the current session; otherwise a localized placeholder.
class AppShellTabGate extends ConsumerWidget {
  const AppShellTabGate({
    super.key,
    required this.tab,
    required this.child,
  });

  final AppShellTabId tab;
  final Widget child;

  String _tabTitle(AppLocalizations l10n) => switch (tab) {
        AppShellTabId.home => l10n.navHome,
        AppShellTabId.clients => l10n.navClients,
        AppShellTabId.directory => l10n.navDirectory,
        AppShellTabId.items => l10n.navItems,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(appShellTabOnlineProvider(tab))) return child;

    final l10n = AppLocalizations.of(context);
    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: context.colors.canvas,
            appBar: FoundationAppBar(
              title: _tabTitle(l10n),
              actions: [
                Semantics(
                  button: true,
                  label: l10n.settingsTitle,
                  child: AppPressable(
                    onPressed: () => showAppSettingsSheet(context),
                    child: Padding(
                    padding: const EdgeInsetsDirectional.all(AppSize.spaceSM),
                    child: ShellNavIcon(
                      asset: Assets.icons.settingsOutline,
                      size: AppSize.icon,
                      color: context.colors.onSurface,
                    ),
                  ),
                ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(AppSize.screenPadding),
              child: AppFallback.section(
                icon: Icons.cloud_off_outlined,
                title: l10n.shellTabNotOnlineTitle,
                description: l10n.shellTabNotOnlineDescription,
              ),
            ),
          );
        },
      ),
    );
  }
}
