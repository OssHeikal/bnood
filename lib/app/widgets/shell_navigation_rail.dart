import 'package:flutter/material.dart';

import '../../core/config/theme/app_size.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_pressable.dart';
import 'shell_nav_destination.dart';
import 'shell_nav_icon.dart';
import 'shell_nav_icons.dart';

/// Side navigation for desktop shell (replaces [FloatingShellDock] at 1024+).
class ShellNavigationRail extends StatelessWidget {
  static const voucherButtonKey = Key('shell-rail-voucher');

  /// Painted destination icon size on tablet/desktop rail.
  static const destinationIconSize = 27.0;

  /// Minimum painted rail width (Material [NavigationRail] slot).
  static const railMinWidth = 100.0;

  const ShellNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onVoucher,
    required this.destinations,
    required this.voucherSemanticsLabel,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onVoucher;
  final List<ShellNavDestination> destinations;
  final String voucherSemanticsLabel;

  static Color _tabFill(Brightness brightness) {
    return brightness == Brightness.dark
        ? AppColors.primary.withValues(alpha: 0.22)
        : AppColors.primary.withValues(alpha: 0.12);
  }

  static ({Color activeIcon, Color inactiveIcon, Color activeLabel, Color inactiveLabel}) _colors(
    BuildContext context,
  ) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final inactiveIcon = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final activeIcon = isDark ? AppColors.primary : AppColors.primaryDark;
    const activeLabel = AppColors.primary;
    return (activeIcon: activeIcon, inactiveIcon: inactiveIcon, activeLabel: activeLabel, inactiveLabel: inactiveIcon);
  }

  Widget _destinationIcon({required ShellNavDestination destination, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSize.spaceSM),
      child: ShellNavIcon(
        asset: destination.icon,
        color: color,
        size: destinationIconSize,
        semanticsLabel: destination.semanticsLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final palette = _colors(context);
    final textTheme = Theme.of(context).textTheme;
    final labelSelected = (textTheme.labelLarge ?? textTheme.labelMedium ?? const TextStyle(fontSize: 14)).copyWith(
      fontWeight: FontWeight.w700,
      color: palette.activeLabel,
      height: 1.2,
    );
    final labelUnselected = (textTheme.labelMedium ?? textTheme.labelLarge ?? const TextStyle(fontSize: 13)).copyWith(
      fontWeight: FontWeight.w500,
      color: palette.inactiveLabel,
      height: 1.2,
    );

    final voucherLeading = Padding(
      padding: const EdgeInsets.only(bottom: AppSize.spaceLG),
      child: Semantics(
        button: true,
        label: voucherSemanticsLabel,
        explicitChildNodes: true,
        child: AppPressable(
          onPressed: onVoucher,
          child: Material(
            key: voucherButtonKey,
            elevation: isDark ? 4 : 8,
            shadowColor: Colors.black26,
            color: AppColors.primary,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: AppSize.shellDockPillExtent,
              height: AppSize.shellDockPillExtent,
              child: Center(
                child: ShellNavIcon(asset: ShellNavIcons.voucherAdd, color: Colors.white, size: AppSize.icon),
              ),
            ),
          ),
        ),
      ),
    );

    return NavigationRailTheme(
      data: NavigationRailThemeData(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightSurface,
        indicatorColor: _tabFill(brightness),
        minWidth: railMinWidth,
        minExtendedWidth: railMinWidth,
        selectedIconTheme: IconThemeData(color: palette.activeIcon, size: destinationIconSize),
        unselectedIconTheme: IconThemeData(color: palette.inactiveIcon, size: destinationIconSize),
        selectedLabelTextStyle: labelSelected,
        unselectedLabelTextStyle: labelUnselected,
      ),
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        labelType: NavigationRailLabelType.all,
        useIndicator: true,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSize.radiusMD)),
        groupAlignment: -1,
        leading: voucherLeading,
        destinations: [
          for (var i = 0; i < destinations.length; i++)
            NavigationRailDestination(
              icon: _destinationIcon(destination: destinations[i], color: palette.inactiveIcon),
              selectedIcon: _destinationIcon(destination: destinations[i], color: palette.activeIcon),
              padding: const EdgeInsets.symmetric(vertical: AppSize.spaceXS),
              label: Text(destinations[i].label),
            ),
        ],
      ),
    );
  }
}
