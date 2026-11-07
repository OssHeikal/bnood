import 'package:flutter/material.dart';

import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/skeleton/skeleton_box.dart';
import '../../../core/widgets/skeleton/skeleton_text.dart';

class CraftsmanDetailLoadingSkeleton extends StatelessWidget {
  const CraftsmanDetailLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LaborStatSkeleton(),
        SizedBox(height: AppSize.spaceXL),
        SkeletonText(role: SkeletonTextRole.title, width: 120),
        SizedBox(height: AppSize.spaceSM),
        _JobCardSkeleton(),
        SizedBox(height: AppSize.spaceXL),
        SkeletonText(role: SkeletonTextRole.title, width: 130),
        SizedBox(height: AppSize.spaceSM),
        _HistoryCardSkeleton(),
      ],
    );
  }
}

class _LaborStatSkeleton extends StatelessWidget {
  const _LaborStatSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkeletonText(role: SkeletonTextRole.label, width: 150),
          SizedBox(height: AppSize.spaceMD),
          SkeletonText(role: SkeletonTextRole.body, width: 100),
          SizedBox(height: AppSize.spaceSM),
          SkeletonText(role: SkeletonTextRole.label, width: 200),
        ],
      ),
    );
  }
}

class _JobCardSkeleton extends StatelessWidget {
  const _JobCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkeletonText(role: SkeletonTextRole.body, width: 100),
          SizedBox(height: AppSize.spaceMD),
          Row(
            children: [
              Expanded(child: SkeletonText(role: SkeletonTextRole.label, width: 40)),
              Expanded(child: SkeletonText(role: SkeletonTextRole.label, width: 40)),
              Expanded(child: SkeletonText(role: SkeletonTextRole.label, width: 40)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryCardSkeleton extends StatelessWidget {
  const _HistoryCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < 2; i++) ...[
            if (i > 0) const SizedBox(height: AppSize.spaceMD),
            const SkeletonText(role: SkeletonTextRole.label, width: 72),
            const SizedBox(height: AppSize.spaceXS),
            const _MovementRowSkeleton(),
          ],
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
              SkeletonText(role: SkeletonTextRole.body, width: 80),
              SizedBox(height: AppSize.spaceXS),
              SkeletonText(role: SkeletonTextRole.label, width: 64),
            ],
          ),
        ),
        SkeletonText(role: SkeletonTextRole.label, width: 48),
      ],
    );
  }
}
