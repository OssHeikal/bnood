import 'package:flutter/material.dart';

import '../../config/extensions/num_extensions.dart';
import '../../config/theme/app_size.dart';
import '../app_card.dart';
import 'skeleton_box.dart';
import 'skeleton_text.dart';

/// Default first-page loading placeholder for paginated person-style lists.
class PagedListSkeleton extends StatelessWidget {
  const PagedListSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++) ...[if (i > 0) AppSize.spaceMD.gap, const _PersonCardBone()],
      ],
    );
  }
}

class _PersonCardBone extends StatelessWidget {
  const _PersonCardBone();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG, vertical: AppSize.spaceMD),
        child: Row(
          children: [
            const SkeletonBox.round(size: AppSize.hitMin),
            AppSize.spaceMD.gap,
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SkeletonText(role: SkeletonTextRole.body, width: 120),
                  SizedBox(height: AppSize.spaceXS),
                  SkeletonText(role: SkeletonTextRole.label, width: 56),
                  SizedBox(height: AppSize.spaceXS),
                  SkeletonText(role: SkeletonTextRole.label, width: 72),
                ],
              ),
            ),
            AppSize.spaceMD.gap,
            const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SkeletonBox(width: 72, height: 14, radius: AppSize.radiusSM),
                SizedBox(height: AppSize.spaceXS),
                SkeletonBox(width: 72, height: 14, radius: AppSize.radiusSM),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
