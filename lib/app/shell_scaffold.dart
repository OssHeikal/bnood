import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/config/theme/app_size.dart';
import '../core/layout/app_layout.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/toast/shell_dock_presence.dart';
import '../features/vouchers/presentation/voucher_launcher.dart';
import 'shell_chrome_scope.dart';
import 'widgets/floating_shell_dock.dart';
import 'widgets/shell_nav_destination.dart';
import 'widgets/shell_nav_icons.dart';
import 'widgets/shell_navigation_rail.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  List<ShellNavDestination> _destinations(AppLocalizations l10n) => [
    ShellNavDestination(icon: ShellNavIcons.home, label: l10n.navHome, semanticsLabel: l10n.navHome),
    ShellNavDestination(icon: ShellNavIcons.clients, label: l10n.navClients, semanticsLabel: l10n.navClients),
    ShellNavDestination(icon: ShellNavIcons.directory, label: l10n.navDirectory, semanticsLabel: l10n.navDirectory),
    ShellNavDestination(icon: ShellNavIcons.items, label: l10n.navItems, semanticsLabel: l10n.navItems),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = _destinations(l10n);
    final voucherLabel = l10n.navAdd;

    if (context.isDesktopLayout) {
      ShellDockPresence.register(context, hasDock: false);
      return Scaffold(
        body: Row(
          children: [
            ShellNavigationRail(
              selectedIndex: navigationShell.currentIndex,
              destinations: destinations,
              onDestinationSelected: navigationShell.goBranch,
              onVoucher: () => VoucherLauncher.openFresh(context),
              voucherSemanticsLabel: voucherLabel,
            ),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final showShellDock = !keyboardOpen;
    // Toasts resolve dock visibility at show time (sheets/dialogs above the shell keep it).
    ShellDockPresence.register(context, hasDock: true);
    final dockClearance = keyboardOpen ? 0.0 : FloatingShellDock.clearanceHeight;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final fadeHeight = dockClearance + safeBottom + AppSize.spaceXL;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MediaQuery(
            data: MediaQuery.of(context).copyWith(
              viewInsets: EdgeInsets.zero,
              padding: MediaQuery.paddingOf(
                context,
              ).copyWith(bottom: MediaQuery.paddingOf(context).bottom + dockClearance),
            ),
            child: ShellChromeScope(keyboardOpen: keyboardOpen, child: navigationShell),
          ),
          if (showShellDock) ...[
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: fadeHeight,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 0.55, 1],
                      colors: [
                        (isDark ? AppColors.darkBg : AppColors.lightSurface).withValues(alpha: 0),
                        (isDark ? AppColors.darkBg : AppColors.lightSurface).withValues(alpha: 0.65),
                        isDark ? AppColors.darkBg : AppColors.lightSurface,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingShellDock(
                selectedIndex: navigationShell.currentIndex,
                destinations: destinations,
                onDestinationSelected: navigationShell.goBranch,
                onVoucher: () => VoucherLauncher.openFresh(context),
                voucherSemanticsLabel: voucherLabel,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
