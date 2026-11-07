import 'package:flutter/material.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_motion.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_pressable.dart';
import 'shell_nav_destination.dart';
import 'shell_nav_icon.dart';
import 'shell_nav_icons.dart';

/// Floating pill nav + satellite voucher control (implementation-side end placement).
class FloatingShellDock extends StatelessWidget {
  const FloatingShellDock({
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

  static const clearanceHeight = AppSize.shellDockClearance;
  /// Shared painted extent for pill track and voucher disc (see [AppSize.shellDockPillExtent]).
  static const pillTrackExtent = AppSize.shellDockPillExtent;
  static const voucherDiscDiameter = AppSize.shellDockVoucherDiameter;
  static const voucherSatelliteSize = AppSize.shellDockPillExtent;
  /// Horizontal inset for dock row (pill + satellite). Tighter than screen padding to widen pill.
  static const horizontalInset = AppSize.spaceMD;
  /// Caps pill+satellite group on wide layouts; phone uses nearly full width minus [horizontalInset].
  static const maxDockGroupWidth = 520.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final labelSize = (11 / scale).clamp(10.0, 13.0);

    final pill = Material(
      elevation: isDark ? 4 : 8,
      shadowColor: Colors.black26,
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: pillTrackExtent,
        width: double.infinity,
        child: Row(
          children: [
            for (var i = 0; i < destinations.length; i++)
              Expanded(
                child: _DockTab(
                  destination: destinations[i],
                  selected: selectedIndex == i,
                  labelSize: labelSize,
                  onTap: () => onDestinationSelected(i),
                ),
              ),
          ],
        ),
      ),
    );

    final voucherHit = Semantics(
      button: true,
      label: voucherSemanticsLabel,
      child: AppPressable(
        onPressed: onVoucher,
        child: SizedBox(
          width: pillTrackExtent,
          height: pillTrackExtent,
          child: Center(
            child: Material(
              elevation: isDark ? 4 : 8,
              shadowColor: Colors.black26,
              color: AppColors.primary,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: voucherDiscDiameter,
                height: voucherDiscDiameter,
                child: Center(
                  child: ShellNavIcon(
                    asset: ShellNavIcons.voucherAdd,
                    color: Colors.white,
                    size: AppSize.icon,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        left: horizontalInset,
        right: horizontalInset,
        bottom: bottom + AppSize.spaceSM,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final groupWidth = constraints.maxWidth.clamp(0.0, maxDockGroupWidth);
          final dockRow = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: pill),
              AppSize.spaceSM.gap,
              voucherHit,
            ],
          );
          final bar = SizedBox(width: groupWidth, child: dockRow);
          final heavyText = MediaQuery.textScalerOf(context).scale(1) > 1.35;
          return Align(
            alignment: Alignment.bottomCenter,
            child: heavyText
                ? FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.bottomCenter, child: bar)
                : bar,
          );
        },
      ),
    );
  }
}

class _DockTab extends StatelessWidget {
  const _DockTab({
    required this.destination,
    required this.selected,
    required this.labelSize,
    required this.onTap,
  });

  final ShellNavDestination destination;
  final bool selected;
  final double labelSize;
  final VoidCallback onTap;

  Color _tabFill(Brightness brightness) {
    return brightness == Brightness.dark
        ? AppColors.primary.withValues(alpha: 0.22)
        : AppColors.primary.withValues(alpha: 0.12);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final inactiveIcon = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final inactiveLabel = inactiveIcon;
    final activeIcon = isDark ? AppColors.primary : AppColors.primaryDark;
    final activeLabel = AppColors.primary;

    final iconColor = selected ? activeIcon : inactiveIcon;
    final labelColor = selected ? activeLabel : inactiveLabel;
    final labelWeight = selected ? FontWeight.w700 : FontWeight.w500;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.semanticsLabel,
      child: AppPressable(
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSize.spaceXS,
            AppSize.spaceXS,
            AppSize.spaceXS,
            AppSize.spaceXS,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final overlayHeight = constraints.maxHeight;
              final stadium = BorderRadius.circular(overlayHeight / 2);
              return AnimatedContainer(
                duration: AppMotion.durationOf(context, AppMotion.stateSwap),
                curve: AppMotion.standard,
                height: overlayHeight,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: selected ? _tabFill(brightness) : Colors.transparent,
                  borderRadius: stadium,
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceXS),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShellNavIcon(
                      asset: destination.icon,
                      color: iconColor,
                      size: AppSize.iconCompact,
                    ),
                    const SizedBox(height: AppSize.spaceXS),
                    Text(
                      destination.label,
                      style: TextStyle(
                        fontSize: labelSize,
                        fontWeight: labelWeight,
                        color: labelColor,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
