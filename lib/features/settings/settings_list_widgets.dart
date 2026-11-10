import 'package:flutter/material.dart';

import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/widgets/app_chevron.dart';
import '../../core/widgets/app_pressable.dart';
import '../../core/widgets/grouped_list_divider.dart';
import '../../app/widgets/shell_nav_icon.dart';
import 'widgets/menu_icon_chip.dart';

class SettingsListSection extends StatelessWidget {
  const SettingsListSection({
    super.key,
    required this.title,
    required this.children,
    required this.dividerKind,
  });

  final String? title;
  final List<Widget> children;
  final GroupedListDividerKind dividerKind;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AppSize.spaceLG, 0, AppSize.spaceLG, AppSize.spaceSM),
            child: Text(
              title!,
              style: context.text.groupTitle,
              textAlign: TextAlign.start,
            ),
          ),
        ],
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

class SettingsDestructiveRow extends StatelessWidget {
  const SettingsDestructiveRow({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final SvgGenImage? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return Semantics(
      button: true,
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
                if (icon != null) ...[
                  MenuIconChip(
                    icon: icon!,
                    backgroundColor: colors.error.withValues(alpha: 0.12),
                    iconColor: colors.error,
                  ),
                  const SizedBox(width: AppSize.spaceMD),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: text.bodyEmphasis.copyWith(color: colors.error),
                    textAlign: TextAlign.start,
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

class SettingsOptionRow extends StatelessWidget {
  const SettingsOptionRow({
    super.key,
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

class SettingsNavRow extends StatelessWidget {
  const SettingsNavRow({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.chipBackground,
    this.iconColor,
    this.showChevron = true,
  });

  final String label;
  final VoidCallback onTap;
  final SvgGenImage? icon;
  final Color? chipBackground;
  final Color? iconColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final chipBg = chipBackground ?? colors.primary.withValues(alpha: 0.12);
    final glyph = iconColor ?? colors.primary;

    return Semantics(
      button: true,
      label: label,
      child: AppPressable(
        onPressed: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSize.hitMin),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSize.spaceMD,
              AppSize.spaceSM + 2,
              AppSize.spaceSM,
              AppSize.spaceSM + 2,
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  MenuIconChip(icon: icon!, backgroundColor: chipBg, iconColor: glyph),
                  const SizedBox(width: AppSize.spaceMD),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: text.body,
                    textAlign: TextAlign.start,
                  ),
                ),
                if (showChevron) const AppChevron.forward(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
