import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/skeleton/skeleton_box.dart';
import '../../../core/widgets/skeleton/skeleton_text.dart';

class SupplierDetailLoadingSkeleton extends StatelessWidget {
  const SupplierDetailLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SpendStatSkeleton(),
        AppSize.spaceXL.gap,
        const SkeletonText(role: SkeletonTextRole.title, width: 120),
        AppSize.spaceSM.gap,
        const _HistoryCardSkeleton(),
      ],
    );
  }
}

class SupplierDetailSpendStatSkeleton extends StatelessWidget {
  const SupplierDetailSpendStatSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const _SpendStatSkeleton();
}

class _SpendStatSkeleton extends StatelessWidget {
  const _SpendStatSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkeletonText(role: SkeletonTextRole.label, width: 160),
          SizedBox(height: AppSize.spaceMD),
          SkeletonText(role: SkeletonTextRole.body, width: 100),
          SizedBox(height: AppSize.spaceSM),
          SkeletonText(role: SkeletonTextRole.label, width: 200),
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
