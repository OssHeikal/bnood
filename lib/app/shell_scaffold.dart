import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/account/account_context_providers.dart';
import '../core/account/account_office_providers.dart';
import '../core/services/config/theme/app_size.dart';
import '../core/ui/layout/app_layout.dart';
import '../core/ui/theme/app_colors.dart';
import '../core/ui/widgets/toast/shell_dock_presence.dart';
import 'package:bnood/features/vouchers/presentation/actions/voucher_launcher.dart';
import 'shell_chrome_scope.dart';
import 'widgets/context_nav_avatar.dart';
import 'widgets/floating_shell_dock.dart';
import 'widgets/shell_nav_destination.dart';
import 'widgets/shell_nav_icons.dart';
import 'widgets/shell_navigation_rail.dart';

class ShellScaffold extends ConsumerStatefulWidget {
  const ShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static int get moreBranchIndex => ShellNavBranch.more.routerIndex;

  @override
  ConsumerState<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends ConsumerState<ShellScaffold> {
  DateTime? _lastMoreRailTapAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirectHiddenBranch());
  }

  void _redirectHiddenBranch() {
    if (!mounted) return;
    final branches = ref.read(shellVisibleBranchIndicesProvider);
    final current = widget.navigationShell.currentIndex;
    if (branches.contains(current)) return;
    widget.navigationShell.goBranch(
      branches.isNotEmpty ? branches.first : ShellNavBranch.home.routerIndex,
    );
  }

  List<ShellNavDestination> _destinations(
    AppLocalizations l10n,
    bool isPersonal,
    List<int> visibleBranches,
  ) {
    final moreLabel = isPersonal ? l10n.navMorePersonal : l10n.navMoreOffice;
    ShellNavDestination? destinationFor(ShellNavBranch branch) {
      return switch (branch) {
        ShellNavBranch.home => ShellNavDestination(
          icon: ShellNavIcons.home,
          label: l10n.navHome,
          semanticsLabel: l10n.navHome,
        ),
        ShellNavBranch.projects => ShellNavDestination(
          icon: ShellNavIcons.projects,
          label: l10n.navProjects,
          semanticsLabel: l10n.navProjects,
        ),
        ShellNavBranch.providers => ShellNavDestination(
          icon: ShellNavIcons.providers,
          label: l10n.navProviders,
          semanticsLabel: l10n.navProviders,
        ),
        ShellNavBranch.more => ShellNavDestination(
          label: moreLabel,
          semanticsLabel: moreLabel,
          tabBuilder: (context, {required selected, required labelSize, required onTap}) {
            return ContextNavAvatarTab(
              selected: selected,
              labelSize: labelSize,
              label: moreLabel,
              semanticsLabel: moreLabel,
              onSelectTab: onTap,
            );
          },
        ),
      };
    }

    return [
      for (final index in visibleBranches)
        destinationFor(ShellNavBranch.values.firstWhere((b) => b.routerIndex == index))!,
    ];
  }

  int? _moreDockIndex(List<int> visibleBranches) {
    final idx = visibleBranches.indexOf(ShellScaffold.moreBranchIndex);
    return idx >= 0 ? idx : null;
  }

  int _dockIndexForBranch(int branchIndex, List<int> visibleBranches) {
    final idx = visibleBranches.indexOf(branchIndex);
    return idx >= 0 ? idx : 0;
  }

  void _onDestinationSelected(int dockIndex, List<int> visibleBranches) {
    final branchIndex = visibleBranches[dockIndex];
    if (branchIndex == ShellScaffold.moreBranchIndex && context.isDesktopLayout) {
      final now = DateTime.now();
      final visible = ref.read(accountSwitcherVisibleProvider);
      if (visible &&
          _lastMoreRailTapAt != null &&
          now.difference(_lastMoreRailTapAt!) <
              const Duration(milliseconds: 300)) {
        unawaited(HapticFeedback.lightImpact());
        unawaited(
          ref.read(accountContextProvider.notifier).quickSwitchToPreviousScope(),
        );
      }
      _lastMoreRailTapAt = now;
    }
    widget.navigationShell.goBranch(branchIndex);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(shellVisibleBranchIndicesProvider, (previous, next) {
      if (previous != next) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _redirectHiddenBranch());
      }
    });
    final l10n = AppLocalizations.of(context);
    final isPersonal = ref.watch(accountContextProvider.select((s) => s.isPersonal));
    final visibleBranches = ref.watch(shellVisibleBranchIndicesProvider);
    final destinations = _destinations(l10n, isPersonal, visibleBranches);
    final selectedDockIndex = _dockIndexForBranch(
      widget.navigationShell.currentIndex,
      visibleBranches,
    );
    final moreDockIndex = _moreDockIndex(visibleBranches);
    final showVoucher = ref.watch(accountOfficeCanCreateVoucherProvider);
    final voucherLabel = l10n.navAdd;

    if (context.isDesktopLayout) {
      ShellDockPresence.register(context, hasDock: false);
      return Scaffold(
        body: Row(
          children: [
            ShellNavigationRail(
              selectedIndex: selectedDockIndex,
              destinations: destinations,
              moreTabIndex: moreDockIndex,
              onDestinationSelected: (i) => _onDestinationSelected(i, visibleBranches),
              onVoucher: () => VoucherLauncher.openFresh(context),
              voucherSemanticsLabel: voucherLabel,
              showVoucher: showVoucher,
            ),
            Expanded(child: widget.navigationShell),
          ],
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final showShellDock = !keyboardOpen;
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
              padding: MediaQuery.paddingOf(context).copyWith(
                bottom: MediaQuery.paddingOf(context).bottom + dockClearance,
              ),
            ),
            child: ShellChromeScope(
              keyboardOpen: keyboardOpen,
              child: widget.navigationShell,
            ),
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
                        (isDark ? AppColors.darkBg : AppColors.lightSurface)
                            .withValues(alpha: 0),
                        (isDark ? AppColors.darkBg : AppColors.lightSurface)
                            .withValues(alpha: 0.65),
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
                selectedIndex: selectedDockIndex,
                destinations: destinations,
                onDestinationSelected: (i) => _onDestinationSelected(i, visibleBranches),
                onVoucher: () => VoucherLauncher.openFresh(context),
                voucherSemanticsLabel: voucherLabel,
                showVoucher: showVoucher,
              ),
            ),
          ],
        ],
      ),
    );
  }
}