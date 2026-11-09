import 'package:flutter/material.dart';

import '../../../core/config/theme/app_size.dart';
import '../../../features/home/widgets/home_loading_skeleton.dart';

/// Mirrors a short provider list inside real scroll padding.
class ProvidersLoadingSkeleton extends StatelessWidget {
  const ProvidersLoadingSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
      child: HomePersonListSkeleton(count: count),
    );
  }
}
