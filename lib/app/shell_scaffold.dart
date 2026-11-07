import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../features/vouchers/voucher_launcher.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton.large(
        onPressed: () => VoucherLauncher.openFresh(context),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex >= 2
            ? navigationShell.currentIndex + 1
            : navigationShell.currentIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            VoucherLauncher.openFresh(context);
            return;
          }
          final branch = index > 2 ? index - 1 : index;
          navigationShell.goBranch(branch);
        },
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n.navHome),
          NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: l10n.navClients),
          const NavigationDestination(icon: Icon(Icons.add), label: ''),
          NavigationDestination(
              icon: const Icon(Icons.storefront_outlined),
              selectedIcon: const Icon(Icons.storefront),
              label: l10n.navDirectory),
          NavigationDestination(
              icon: const Icon(Icons.category_outlined),
              selectedIcon: const Icon(Icons.category),
              label: l10n.navItems),
        ],
      ),
    );
  }
}
