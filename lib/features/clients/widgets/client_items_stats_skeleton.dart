import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/skeleton/skeleton_box.dart';
import '../../../core/widgets/skeleton/skeleton_text.dart';

class ClientItemsStatsSkeleton extends StatelessWidget {
  const ClientItemsStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) AppSize.spaceMD.gap,
          AppCard(
            padding: const EdgeInsets.all(AppSize.spaceLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    SkeletonBox.round(size: AppSize.statIconBox),
                    SizedBox(width: AppSize.spaceMD),
                    Expanded(child: SkeletonText(role: SkeletonTextRole.body, width: 120)),
                    SkeletonText(role: SkeletonTextRole.label, width: 56),
                  ],
                ),
                AppSize.spaceMD.gap,
                const SkeletonText(role: SkeletonTextRole.supporting, width: 180),
                AppSize.spaceSM.gap,
                const SkeletonBox(height: 8),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
