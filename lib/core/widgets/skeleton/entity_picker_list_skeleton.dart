import 'package:flutter/material.dart';

import '../../config/theme/app_size.dart';
import '../entity_picker_row.dart';
import 'skeleton.dart';
import 'skeleton_box.dart';
import 'skeleton_text.dart';

/// List-shaped pulse placeholder for [EntityPickerPage] while roster loads.
class EntityPickerListSkeleton extends StatelessWidget {
  const EntityPickerListSkeleton({super.key, this.rowCount = 6});

  final int rowCount;

  static const _leadingSize = AppSize.hitMin;

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: AppSize.spaceLG),
        itemCount: rowCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SkeletonBox(height: _leadingSize, width: _leadingSize),
                    const SizedBox(width: AppSize.spaceMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonText(role: SkeletonTextRole.body),
                          SizedBox(height: AppSize.spaceXS),
                          SkeletonText(role: SkeletonTextRole.supporting, width: 120),
                        ],
                      ),
                    ),
                  ],
                ),
                if (index < rowCount - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: EntityPickerOptionRow.dividerStartInset(_leadingSize),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}