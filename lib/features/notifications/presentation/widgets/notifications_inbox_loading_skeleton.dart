import 'package:flutter/material.dart';

import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/ui/widgets/app_card.dart';
import '../../../../core/ui/widgets/skeleton/skeleton_box.dart';
import '../../../../core/ui/widgets/skeleton/skeleton_text.dart';

class NotificationsInboxLoadingSkeleton extends StatelessWidget {
  const NotificationsInboxLoadingSkeleton({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
      child: Column(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(height: AppSize.spaceSM),
            const _NotificationRowSkeleton(),
          ],
        ],
      ),
    );
  }
}

class _NotificationRowSkeleton extends StatelessWidget {
  const _NotificationRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 44, height: 44),
          const SizedBox(width: AppSize.spaceMD),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(role: SkeletonTextRole.title),
                SizedBox(height: AppSize.spaceXS),
                SkeletonText(role: SkeletonTextRole.body),
                SizedBox(height: AppSize.spaceXS),
                SkeletonText(role: SkeletonTextRole.label),
              ],
            ),
          ),
        ],
      ),
    );
  }
}