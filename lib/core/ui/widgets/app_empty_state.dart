import 'package:flutter/material.dart';

import '../../services/config/extensions/num_extensions.dart';
import '../../services/config/theme/app_colors.dart';
import '../../services/config/theme/app_size.dart';
import 'buttons/app_button.dart';

/// Centered list/tab empty state: tinted icon disc, title, optional subtitle and primary CTA.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    this.icon,
    this.leading,
    required this.title,
    this.description,
    this.primaryActionLabel,
    this.onPrimaryAction,
  }) : assert(icon != null || leading != null, 'Provide icon or leading');

  final IconData? icon;
  final Widget? leading;
  final String title;
  final String? description;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;

  static const _iconDiscSize = 72.0;
  static const _bodyMaxWidth = 320.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    final glyph =
        leading ??
        Icon(icon, size: AppSize.iconExtraLarge, color: colors.primary);

    return Semantics(
      container: true,
      label: title,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _bodyMaxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: _iconDiscSize,
                height: _iconDiscSize,
                child: Center(child: glyph),
              ),
            ),
            AppSize.spaceLG.gap,
            Text(title, style: text.sectionTitle, textAlign: TextAlign.center),
            if (description != null) ...[
              AppSize.spaceSM.gap,
              Text(
                description!,
                style: text.supporting.copyWith(color: colors.onSurfaceMuted),
                textAlign: TextAlign.center,
              ),
            ],
            if (primaryActionLabel != null && onPrimaryAction != null) ...[
              AppSize.spaceXL.gap,
              AppButton.primary(
                text: primaryActionLabel!,
                onPressed: onPrimaryAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
