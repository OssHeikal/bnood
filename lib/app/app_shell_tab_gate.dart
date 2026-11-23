import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/config/theme/app_colors.dart';
import '../core/services/config/theme/app_size.dart';
import '../core/ui/widgets/app_fallback.dart';
import '../core/ui/widgets/custom_app_bar.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'app_shell_online_tabs.dart';

/// Renders [child] when the tab is online for the current session; otherwise a localized placeholder.
class AppShellTabGate extends ConsumerWidget {
  const AppShellTabGate({super.key, required this.tab, required this.child});

  final AppShellTabId tab;
  final Widget child;

  String _tabTitle(AppLocalizations l10n) => switch (tab) {
    AppShellTabId.home => l10n.navHome,
    AppShellTabId.projects => l10n.navProjects,
    AppShellTabId.providers => l10n.navProviders,
    AppShellTabId.more => l10n.menuTitle,
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
            appBar: CustomAppBar(
              title: _tabTitle(l10n),
              actions: const [],
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
