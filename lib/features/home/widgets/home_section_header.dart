import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_pressable.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.seeAllLabel,
    this.onSeeAll,
    this.seeAllEnabled = true,
    this.actionLabel,
    this.onAction,
    this.actionEnabled = true,
    this.actionKey,
  });

  final String title;
  final String? seeAllLabel;
  final VoidCallback? onSeeAll;
  final bool seeAllEnabled;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool actionEnabled;
  final Key? actionKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Row(
      children: [
        Expanded(child: Text(title, style: text.sectionTitle)),
        if (actionLabel != null && onAction != null)
          AppPressable(
            key: actionKey,
            enabled: actionEnabled,
            onPressed: actionEnabled ? onAction : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Text(
                actionLabel!,
                style: text.caption.copyWith(
                  color: actionEnabled ? colors.primaryDark : colors.onSurfaceMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        if (seeAllLabel != null && onSeeAll != null) ...[
          if (actionLabel != null) AppSize.spaceSM.gap,
          AppPressable(
            enabled: seeAllEnabled,
            onPressed: onSeeAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Text(
                seeAllLabel!,
                style: text.caption.copyWith(
                  color: seeAllEnabled ? colors.primaryDark : colors.onSurfaceMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
