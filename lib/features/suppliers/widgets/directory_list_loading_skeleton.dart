import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/skeleton/skeleton.dart';
import '../../../core/widgets/skeleton/skeleton_box.dart';
import '../../../core/widgets/skeleton/skeleton_text.dart';

/// First-page placeholder for directory-style person rows (remote providers + local directory).
class DirectoryListLoadingSkeleton extends StatelessWidget {
  const DirectoryListLoadingSkeleton({super.key, this.count = 4, this.gap = AppSize.spaceMD});

  final int count;
  final double gap;

  static const _avatarSize = 40.0;
  static const _stripeWidth = 4.0;
  static const _menuSize = 40.0;

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Column(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) SizedBox(height: gap),
            const DirectoryListRowSkeleton(),
          ],
        ],
      ),
    );
  }
}

/// Mirrors [DirectoryPersonCard] / [ProvidersListTile]: stripe, avatar, text stack, overflow slot.
class DirectoryListRowSkeleton extends StatelessWidget {
  const DirectoryListRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: EdgeInsets.zero,
      radius: AppSize.radiusMD,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: colors.surfaceSunken,
              child: const SizedBox(width: DirectoryListLoadingSkeleton._stripeWidth),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSize.spaceLG,
                  AppSize.spaceMD,
                  AppSize.spaceSM,
                  AppSize.spaceMD,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SkeletonBox.round(size: DirectoryListLoadingSkeleton._avatarSize),
                    AppSize.spaceMD.gap,
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SkeletonText(role: SkeletonTextRole.body, width: 168),
                          SizedBox(height: AppSize.spaceXS),
                          SkeletonText(role: SkeletonTextRole.label, width: 72),
                          SizedBox(height: AppSize.spaceXS),
                          SkeletonText(role: SkeletonTextRole.label, width: 108),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: AppSize.spaceSM),
              child: Center(
                child: SkeletonBox(
                  width: DirectoryListLoadingSkeleton._menuSize,
                  height: DirectoryListLoadingSkeleton._menuSize,
                  radius: AppSize.radiusSM,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
