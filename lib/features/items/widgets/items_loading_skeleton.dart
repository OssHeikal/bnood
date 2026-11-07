import 'package:flutter/material.dart';

import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/skeleton/skeleton_box.dart';
import '../../../core/widgets/skeleton/skeleton_text.dart';

class ItemsLoadingSkeleton extends StatelessWidget {
  const ItemsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSize.spaceMD,
        mainAxisSpacing: AppSize.spaceMD,
        mainAxisExtent: 116,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return AppCard(
          padding: const EdgeInsets.all(AppSize.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBox.round(size: 40),
              const Spacer(),
              const SkeletonText(role: SkeletonTextRole.body, width: 72),
            ],
          ),
        );
      },
    );
  }
}
