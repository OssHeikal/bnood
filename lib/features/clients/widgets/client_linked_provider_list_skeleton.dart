import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/skeleton/skeleton.dart';
import '../../../core/widgets/skeleton/skeleton_box.dart';
import '../../../core/widgets/skeleton/skeleton_text.dart';

/// Loading placeholder matching [ClientDetailCraftsmanRow] (RTL-safe layout).
class ClientLinkedProviderListSkeleton extends StatelessWidget {
  const ClientLinkedProviderListSkeleton({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < count; i++) ...[if (i > 0) AppSize.spaceMD.gap, const _LinkedProviderRowBone()],
        ],
      ),
    );
  }
}

class _LinkedProviderRowBone extends StatelessWidget {
  const _LinkedProviderRowBone();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSize.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SkeletonBox.round(size: 36),
              const SizedBox(width: AppSize.spaceSM),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SkeletonText(role: SkeletonTextRole.body, width: 140),
                    SizedBox(height: AppSize.spaceXS),
                    SkeletonText(role: SkeletonTextRole.label, width: 72),
                  ],
                ),
              ),
              const SizedBox(width: AppSize.spaceSM),
              SkeletonBox(width: 16, height: 16, radius: AppSize.radiusSM),
            ],
          ),
          AppSize.spaceMD.gap,
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < 3; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(end: i < 2 ? AppSize.spaceXS : 0),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SkeletonText(role: SkeletonTextRole.label, width: 48),
                          SizedBox(height: AppSize.spaceXS),
                          SkeletonBox(width: 56, height: 16, radius: AppSize.radiusSM),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
