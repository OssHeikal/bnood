import 'package:flutter/material.dart';

import '../../../../core/widgets/skeleton/skeleton.dart';
import '../../../../core/widgets/skeleton/skeleton_box.dart';

class PaywallLoadingSkeleton extends StatelessWidget {
  const PaywallLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            const SkeletonBox(width: 240, height: 26),
            const SizedBox(height: 8),
            const SkeletonBox(width: 200, height: 12),
            const SizedBox(height: 18),
            for (var i = 0; i < 4; i++) ...[
              const Row(
                children: [
                  SkeletonBox(width: 18, height: 18),
                  SizedBox(width: 8),
                  Expanded(child: SkeletonBox(height: 12)),
                ],
              ),
              const SizedBox(height: 10),
            ],
            const SkeletonBox(height: 40),
            const SizedBox(height: 12),
            const SkeletonBox(height: 54),
            const SizedBox(height: 7),
            const SkeletonBox(height: 66),
            const SizedBox(height: 7),
            const SkeletonBox(height: 54),
          ],
        ),
      ),
    );
  }
}
