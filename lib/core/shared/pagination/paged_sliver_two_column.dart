import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../config/theme/app_size.dart';

/// Paged list with two items per row; row height follows the taller card.
class PagedSliverTwoColumn<PageKeyType, ItemType> extends StatelessWidget {
  const PagedSliverTwoColumn({
    super.key,
    required this.state,
    required this.fetchNextPage,
    required this.builderDelegate,
    this.columnSpacing = AppSize.spaceMD,
    this.rowSpacing = AppSize.spaceMD,
    this.shrinkWrapFirstPageIndicators = false,
  });

  final PagingState<PageKeyType, ItemType> state;
  final NextPageCallback fetchNextPage;
  final PagedChildBuilderDelegate<ItemType> builderDelegate;
  final double columnSpacing;
  final double rowSpacing;
  final bool shrinkWrapFirstPageIndicators;

  SliverMultiBoxAdaptorWidget _buildPairedSliver(
    IndexedWidgetBuilder itemWidgetBuilder,
    int itemCount,
    WidgetBuilder? statusIndicatorBuilder,
  ) {
    final rowCount = itemCount == 0 ? 0 : (itemCount + 1) ~/ 2;
    return SliverList(
      delegate: AppendedSliverChildBuilderDelegate(
        builder: (context, rowIndex) {
          final leftIndex = rowIndex * 2;
          final rightIndex = leftIndex + 1;
          return Padding(
            padding: EdgeInsets.only(bottom: rowSpacing),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: itemWidgetBuilder(context, leftIndex)),
                  SizedBox(width: columnSpacing),
                  Expanded(
                    child: rightIndex < itemCount
                        ? itemWidgetBuilder(context, rightIndex)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: rowCount,
        appendixBuilder: statusIndicatorBuilder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PagedLayoutBuilder<PageKeyType, ItemType>(
      layoutProtocol: PagedLayoutProtocol.sliver,
      state: state,
      fetchNextPage: fetchNextPage,
      builderDelegate: builderDelegate,
      shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
      loadingListingBuilder: (context, itemWidgetBuilder, itemCount, progress) =>
          _buildPairedSliver(itemWidgetBuilder, itemCount, progress),
      errorListingBuilder: (context, itemWidgetBuilder, itemCount, error) =>
          _buildPairedSliver(itemWidgetBuilder, itemCount, error),
      completedListingBuilder: (context, itemWidgetBuilder, itemCount, noMore) =>
          _buildPairedSliver(itemWidgetBuilder, itemCount, noMore),
    );
  }
}
