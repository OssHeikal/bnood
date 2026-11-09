import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/skeleton/skeleton_box.dart';
import '../../../core/widgets/skeleton/skeleton_text.dart';

class ProviderDetailLoadingSkeleton extends StatelessWidget {
  const ProviderDetailLoadingSkeleton({super.key, this.showClients = false});

  final bool showClients;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _IdentitySkeleton(),
        if (showClients) ...[
          AppSize.spaceXL.gap,
          const SkeletonText(role: SkeletonTextRole.title, width: 140),
          AppSize.spaceSM.gap,
          const _ClientCardSkeleton(),
        ],
      ],
    );
  }
}

class _IdentitySkeleton extends StatelessWidget {
  const _IdentitySkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkeletonText(role: SkeletonTextRole.label, width: 48),
          SizedBox(height: AppSize.spaceXS),
          SkeletonText(role: SkeletonTextRole.body, width: 200),
          SizedBox(height: AppSize.spaceMD),
          SkeletonText(role: SkeletonTextRole.label, width: 56),
          SizedBox(height: AppSize.spaceXS),
          SkeletonText(role: SkeletonTextRole.body, width: 120),
        ],
      ),
    );
  }
}

class _ClientCardSkeleton extends StatelessWidget {
  const _ClientCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Row(
        children: [
          SkeletonBox.round(size: 36),
          SizedBox(width: AppSize.spaceSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SkeletonText(role: SkeletonTextRole.body, width: 160),
                SizedBox(height: AppSize.spaceXS),
                SkeletonText(role: SkeletonTextRole.label, width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
