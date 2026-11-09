import 'package:flutter/material.dart';

import '../../suppliers/widgets/directory_list_loading_skeleton.dart';

/// Mirrors provider/directory list rows inside [AppPagedView] content padding.
class ProvidersLoadingSkeleton extends StatelessWidget {
  const ProvidersLoadingSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DirectoryListLoadingSkeleton(count: count);
  }
}
