import 'package:flutter/material.dart';

import '../config/extensions/text_style_extensions.dart';
import '../config/theme/app_size.dart';
import '../config/theme/app_colors.dart';
import 'app_chevron.dart';
import 'app_pressable.dart';
import 'text_field/app_input_direction.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.subtitlePrefix,
    this.trailingText,
    this.trailing,
    this.showChevron = false,
    this.titleColor,
    this.onTap,
    this.enabled = true,
    this.subtitleMaxLines = 1,
    this.subtitleTextDirection,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? subtitlePrefix;
  final String? trailingText;
  final Widget? trailing;
  final bool showChevron;
  final Color? titleColor;
  final VoidCallback? onTap;
  final bool enabled;
  final int subtitleMaxLines;
  final TextDirection? subtitleTextDirection;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveTitleColor = titleColor ?? colors.onSurface;
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;
    final hasTrailingText = trailingText != null && trailingText!.isNotEmpty;

    Widget row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSize.hitMin),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG, vertical: AppSize.spaceMD),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: AppSize.spaceMD)],
            Expanded(
              child: Column(
                spacing: AppSize.spaceXS,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: context.text.body.semiBold.setColor(effectiveTitleColor)),
                  if (hasSubtitle)
                    Row(
                      children: [
                        if (subtitlePrefix != null) ...[subtitlePrefix!, const SizedBox(width: AppSize.spaceXS)],
                        Expanded(
                          child: Text(
                            subtitle!,
                            maxLines: subtitleMaxLines,
                            overflow: TextOverflow.ellipsis,
                            textDirection:
                                subtitleTextDirection ?? inferTextDirection(subtitle!, Directionality.of(context)),
                            textAlign: alignTextInAmbient(subtitle!, Directionality.of(context)),
                            style: context.text.caption.setColor(colors.textTertiary),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (hasTrailingText) ...[
              const SizedBox(width: AppSize.spaceSM),
              Text(trailingText!, style: context.text.caption.setColor(colors.textTertiary)),
            ],
            if (trailing != null) ...[const SizedBox(width: AppSize.spaceSM), trailing!],
            if (showChevron) ...[
              const SizedBox(width: AppSize.spaceSM),
              AppChevron.forward(color: colors.textTertiary, size: AppSize.iconCompact),
            ],
          ],
        ),
      ),
    );

    if (onTap != null) {
      row = AppPressable(onPressed: enabled ? onTap : null, enabled: enabled, child: row);
    }

    if (!enabled) {
      row = Opacity(opacity: 0.55, child: row);
    }

    if (onTap != null) {
      return Semantics(button: true, label: title, enabled: enabled, child: row);
    }

    return row;
  }
}
