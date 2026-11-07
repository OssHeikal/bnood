import 'package:flutter/material.dart';

import '../../../core/config/theme/app_colors.dart';
import '../../../core/widgets/app_pressable.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.seeAllLabel,
    this.onSeeAll,
    this.seeAllEnabled = true,
  });

  final String title;
  final String? seeAllLabel;
  final VoidCallback? onSeeAll;
  final bool seeAllEnabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Row(
      children: [
        Expanded(child: Text(title, style: text.sectionTitle)),
        if (seeAllLabel != null && onSeeAll != null)
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
    );
  }
}
