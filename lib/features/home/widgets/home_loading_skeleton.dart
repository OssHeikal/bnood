import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/skeleton/skeleton_box.dart';
import '../../../core/widgets/skeleton/skeleton_text.dart';

/// Home data zones only — headers/settings/nav stay live outside [Skeleton].
class HomeStatGridSkeleton extends StatelessWidget {
  const HomeStatGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _StatTileBone()),
            AppSize.spaceMD.gap,
            Expanded(child: _StatTileBone()),
          ],
        ),
        AppSize.spaceMD.gap,
        _StatTileBone(wide: true),
      ],
    );
  }
}

class _StatTileBone extends StatelessWidget {
  const _StatTileBone({this.wide = false});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSize.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const SkeletonBox(width: AppSize.statIconBox, height: AppSize.statIconBox),
              AppSize.spaceSM.gap,
              Expanded(
                child: SkeletonText(
                  role: SkeletonTextRole.label,
                  width: wide ? 200 : 72,
                ),
              ),
            ],
          ),
          AppSize.spaceMD.gap,
          SkeletonText(role: SkeletonTextRole.body, width: wide ? 140 : 96),
        ],
      ),
    );
  }
}

class HomePersonListSkeleton extends StatelessWidget {
  const HomePersonListSkeleton({super.key, this.count = 2});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) AppSize.spaceMD.gap,
          const _PersonCardBone(),
        ],
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SkeletonText(role: SkeletonTextRole.body, width: 120),
                  AppSize.spaceXS.gap,
                  Row(
                    children: [
                      const SkeletonBox(width: 64, height: 14, radius: AppSize.radiusSM),
                      AppSize.spaceSM.gap,
                      const SkeletonBox(width: 64, height: 14, radius: AppSize.radiusSM),
                    ],
                  ),
                ],
              ),
            ),
            AppSize.spaceMD.gap,
            const SkeletonText(role: SkeletonTextRole.label, width: 72),
          ],
        ),
      ),
    );
  }
}
