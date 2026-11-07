import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/skeleton/skeleton_box.dart';
import '../../../core/widgets/skeleton/skeleton_text.dart';
import '../../home/widgets/home_loading_skeleton.dart';

/// Client detail body skeleton — stat grid + engineer card + row stacks.
class ClientDetailLoadingSkeleton extends StatelessWidget {
  const ClientDetailLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _EngineerCardSkeleton(),
        AppSize.spaceXL.gap,
        const SkeletonText(role: SkeletonTextRole.title, width: 100),
        AppSize.spaceSM.gap,
        const HomePersonListSkeleton(count: 2),
        AppSize.spaceXL.gap,
        const SkeletonText(role: SkeletonTextRole.title, width: 80),
        AppSize.spaceSM.gap,
        const HomePersonListSkeleton(count: 2),
        AppSize.spaceXL.gap,
        const SkeletonText(role: SkeletonTextRole.title, width: 110),
        AppSize.spaceSM.gap,
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) AppSize.spaceMD.gap,
          const _MovementRowSkeleton(),
        ],
      ],
    );
  }
}

class ClientDetailStatSkeleton extends StatelessWidget {
  const ClientDetailStatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeStatGridSkeleton();
  }
}

class _EngineerCardSkeleton extends StatelessWidget {
  const _EngineerCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkeletonText(role: SkeletonTextRole.body, width: 140),
          SizedBox(height: AppSize.spaceSM),
          SkeletonText(role: SkeletonTextRole.label, width: 100),
          SizedBox(height: AppSize.spaceXS),
          SkeletonText(role: SkeletonTextRole.label, width: 160),
        ],
      ),
    );
  }
}

class _MovementRowSkeleton extends StatelessWidget {
  const _MovementRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBox.round(size: AppSize.statIconBox),
        SizedBox(width: AppSize.spaceMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SkeletonText(role: SkeletonTextRole.body, width: 72),
              SizedBox(height: AppSize.spaceXS),
              SkeletonText(role: SkeletonTextRole.label, width: 120),
            ],
          ),
        ),
        SkeletonText(role: SkeletonTextRole.label, width: 40),
      ],
    );
  }
}
