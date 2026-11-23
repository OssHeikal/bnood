import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/account/account_context_providers.dart';
import '../../core/account/account_office_providers.dart';
import '../../core/domain/formatting/person_initials.dart';
import '../../core/services/config/theme/app_colors.dart';
import '../../core/services/config/theme/app_shape.dart';
import '../../core/services/config/theme/app_size.dart';
import '../../core/ui/theme/app_colors.dart' as ui_colors;
import '../../core/ui/widgets/app_pressable.dart';
import 'package:bnood/features/account/presentation/account_switcher_actions.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'shell_navigation_rail.dart';

/// More-tab control: context photo/initials, instant select, long-press switcher, quick switch.
class ContextNavAvatarTab extends ConsumerStatefulWidget {
  const ContextNavAvatarTab({
    super.key,
    required this.selected,
    required this.labelSize,
    required this.label,
    required this.semanticsLabel,
    required this.onSelectTab,
  });

  final bool selected;
  final double labelSize;
  final String label;
  final String semanticsLabel;
  final VoidCallback onSelectTab;

  @override
  ConsumerState<ContextNavAvatarTab> createState() => _ContextNavAvatarTabState();
}

class _ContextNavAvatarTabState extends ConsumerState<ContextNavAvatarTab> {
  DateTime? _lastTapAt;

  Future<void> _onLongPress(BuildContext context) async {
    if (!ref.read(accountSwitcherVisibleProvider)) return;
    await HapticFeedback.mediumImpact();
    if (!context.mounted) return;
    await showAccountSwitcherSheet(context, ref);
  }

  void _onTap() {
    final now = DateTime.now();
    final visible = ref.read(accountSwitcherVisibleProvider);
    if (visible &&
        _lastTapAt != null &&
        now.difference(_lastTapAt!) < const Duration(milliseconds: 300)) {
      unawaited(HapticFeedback.lightImpact());
      unawaited(
        ref.read(accountContextProvider.notifier).quickSwitchToPreviousScope(),
      );
    }
    _lastTapAt = now;
    widget.onSelectTab();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final inactiveLabel = isDark ? ui_colors.AppColors.darkMuted : ui_colors.AppColors.lightMuted;
    const activeLabel = ui_colors.AppColors.primary;
    final labelColor = widget.selected ? activeLabel : inactiveLabel;
    final labelWeight = widget.selected ? FontWeight.w700 : FontWeight.w500;
    final switcherVisible = ref.watch(accountSwitcherVisibleProvider);
    final l10n = AppLocalizations.of(context);

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.semanticsLabel,
      hint: switcherVisible ? l10n.accountSwitchLongPressHint : null,
      child: GestureDetector(
        onLongPress: switcherVisible ? () => _onLongPress(context) : null,
        child: AppPressable(
          onPressed: _onTap,
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
                  duration: const Duration(milliseconds: 200),
                  height: overlayHeight,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: widget.selected
                        ? (isDark
                            ? ui_colors.AppColors.primary.withValues(alpha: 0.22)
                            : ui_colors.AppColors.primary.withValues(alpha: 0.12))
                        : Colors.transparent,
                    borderRadius: stadium,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceXS),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ContextNavAvatarIcon(selected: widget.selected),
                      const SizedBox(height: AppSize.spaceXS),
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: widget.labelSize,
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
      ),
    );
  }
}

/// Avatar circle for dock, rail, and tests.
class ContextNavAvatarIcon extends ConsumerWidget {
  const ContextNavAvatarIcon({
    super.key,
    required this.selected,
    double? size,
  }) : size = size ?? ShellNavigationRail.destinationIconSize;

  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctx = ref.watch(accountContextProvider);
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String displayName;
    String? imageUrl;
    if (ctx.isPersonal) {
      final user = ref.watch(authControllerProvider.select((s) => s.user));
      displayName = user?.name?.trim() ?? user?.phone ?? '';
      imageUrl = user?.logoUrl;
    } else {
      final office = ref.watch(selectedOfficeMembershipProvider);
      displayName = office?.name ?? '';
      imageUrl = office?.logoUrl;
    }
    final initials = personInitials(displayName);

    final ringColor =
        isDark ? ui_colors.AppColors.primary : ui_colors.AppColors.primaryDark;
    final idleRing = colors.outlineSubtle.withValues(alpha: isDark ? 0.55 : 0.85);

    final face = _AvatarFace(
      size: size,
      imageUrl: imageUrl,
      initials: initials,
      colors: colors,
      selected: selected,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? ringColor : idleRing,
          width: selected ? 2 : 1,
        ),
      ),
      child: face,
    );
  }
}

/// Rail More icon: long-press opens switcher; tab select is owned by [NavigationRail].
class ContextNavAvatarRailDestination extends ConsumerWidget {
  const ContextNavAvatarRailDestination({
    super.key,
    required this.selected,
    required this.semanticsLabel,
  });

  final bool selected;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final switcherVisible = ref.watch(accountSwitcherVisibleProvider);
    final l10n = AppLocalizations.of(context);

    Future<void> onLongPress() async {
      if (!switcherVisible) return;
      await HapticFeedback.mediumImpact();
      if (!context.mounted) return;
      await showAccountSwitcherSheet(context, ref);
    }

    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      hint: switcherVisible ? l10n.accountSwitchLongPressHint : null,
      child: GestureDetector(
        onLongPress: switcherVisible ? onLongPress : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSize.spaceSM),
          child: ContextNavAvatarIcon(
            selected: selected,
            size: ShellNavigationRail.destinationIconSize,
          ),
        ),
      ),
    );
  }
}

class _AvatarFace extends StatelessWidget {
  const _AvatarFace({
    required this.size,
    required this.imageUrl,
    required this.initials,
    required this.colors,
    required this.selected,
  });

  final double size;
  final String? imageUrl;
  final String initials;
  final AppColors colors;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final url = imageUrl?.trim();
    final Widget inner = url != null && url.isNotEmpty
        ? Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _initials(initials, text),
          )
        : _initials(initials, text);

    return Material(
      color: colors.surfaceSunken,
      shape: AppShape.circle,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(width: size, height: size, child: inner),
    );
  }

  Widget _initials(String value, AppText text) {
    return Center(
      child: Text(
        value,
        style: text.bodyEmphasis.copyWith(
          color: selected ? colors.primary : colors.onSurfaceMuted,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}